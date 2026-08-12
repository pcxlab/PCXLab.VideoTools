function Build-PCXSynchronizationTimeline {

    <#
    .SYNOPSIS
        Builds a PCXLab.SynchronizationTimeline from source offsets.

    .DESCRIPTION
        Constructs a synchronized timeline describing the relative timing
        of each source with respect to the reference source. Timeline
        segments are created at every boundary where the set of active
        source contributions changes.

    .PARAMETER ReferenceSource
        PCXLab.MediaSource used as the timing reference.

    .PARAMETER Sources
        All PCXLab.MediaSource objects participating in synchronization.

    .PARAMETER SourceOffsets
        Array of PCXLab.SourceOffset objects.

    .OUTPUTS
        PCXLab.SynchronizationTimeline
    #>

    [CmdletBinding()]
    [OutputType('PCXLab.SynchronizationTimeline')]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$ReferenceSource,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object[]]$Sources,

        [Parameter()]
        [ValidateNotNull()]
        [object[]]$SourceOffsets = @()

    )

    if ($ReferenceSource.PSTypeNames -notcontains 'PCXLab.MediaSource') {
        throw 'ReferenceSource must be a PCXLab.MediaSource object.'
    }

    foreach ($source in $Sources) {
        if ($source.PSTypeNames -notcontains 'PCXLab.MediaSource') {
            throw 'Sources must contain PCXLab.MediaSource objects.'
        }
    }

    $sourceLookup = @{}
    foreach ($source in $Sources) {
        $sourceLookup[$source.Id] = $source
    }

    $referenceDuration = $ReferenceSource.MediaInformation.Duration.TotalSeconds
    $maxEnd = $referenceDuration

    $sourceIntervals = [System.Collections.Generic.List[object]]::new()

    foreach ($offset in $SourceOffsets) {

        if ($offset.PSTypeNames -notcontains 'PCXLab.SourceOffset') {
            throw 'SourceOffsets must contain PCXLab.SourceOffset objects.'
        }

        $source = $sourceLookup[$offset.SourceId]

        if (-not $source) {
            throw "Source with Id '$($offset.SourceId)' was not found."
        }

        $sourceDuration = $source.MediaInformation.Duration.TotalSeconds
        $sourceStart = -$offset.OffsetSeconds
        $sourceEnd = $sourceStart + $sourceDuration

        $sourceIntervals.Add([PSCustomObject]@{
            Source = $source
            Offset = $offset
            Start = $sourceStart
            End = $sourceEnd
        })

        if ($sourceEnd -gt $maxEnd) {
            $maxEnd = $sourceEnd
        }

    }

    # Build boundary set
    $boundaries = [System.Collections.Generic.SortedSet[double]]::new()
    [void]$boundaries.Add(0)
    [void]$boundaries.Add($maxEnd)

    foreach ($interval in $sourceIntervals) {
        $clampedStart = [Math]::Max(0, [Math]::Min($maxEnd, $interval.Start))
        $clampedEnd = [Math]::Max(0, [Math]::Min($maxEnd, $interval.End))
        [void]$boundaries.Add($clampedStart)
        [void]$boundaries.Add($clampedEnd)
    }

    $boundaryArray = [double[]]::new($boundaries.Count)
    $boundaries.CopyTo($boundaryArray)

    # Build segments
    $segments = [System.Collections.Generic.List[object]]::new()

    for ($i = 0; $i -lt ($boundaryArray.Length - 1); $i++) {

        $segmentStart = $boundaryArray[$i]
        $segmentEnd = $boundaryArray[$i + 1]

        if ($segmentEnd -le $segmentStart) { continue }

        $contributions = [System.Collections.Generic.List[object]]::new()

        # Reference contribution
        if (0 -le $segmentStart -and $referenceDuration -ge $segmentEnd) {

            $referenceContribution = New-PCXSynchronizationContributionObject `
                -SourcePath $ReferenceSource.Path `
                -Role $ReferenceSource.Role `
                -OffsetSeconds 0 `
                -TrimStart $segmentStart `
                -TrimEnd $segmentEnd

            $contributions.Add($referenceContribution)

        }

        # Source contributions active across the entire segment
        foreach ($interval in $sourceIntervals) {

            if ($interval.Start -le $segmentStart -and $interval.End -ge $segmentEnd) {

                $sourceContribution = New-PCXSynchronizationContributionObject `
                    -SourcePath $interval.Source.Path `
                    -Role $interval.Source.Role `
                    -OffsetSeconds $interval.Offset.OffsetSeconds `
                    -TrimStart ($segmentStart - $interval.Start) `
                    -TrimEnd ($segmentEnd - $interval.Start)

                $contributions.Add($sourceContribution)

            }

        }

        if ($contributions.Count -eq 0) { continue }

        $segment = New-PCXSynchronizationSegmentObject `
            -StartSeconds $segmentStart `
            -EndSeconds $segmentEnd `
            -Contributions $contributions

        $segments.Add($segment)

    }

    New-PCXSynchronizationTimelineObject `
        -ReferenceId $ReferenceSource.Id `
        -ReferencePath $ReferenceSource.Path `
        -ReferenceDuration ([TimeSpan]::FromSeconds($referenceDuration)) `
        -SourceOffsets $SourceOffsets `
        -TotalDuration ([TimeSpan]::FromSeconds($maxEnd)) `
        -Segments $segments

}
