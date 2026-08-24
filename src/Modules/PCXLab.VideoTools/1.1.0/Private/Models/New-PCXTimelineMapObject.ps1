function New-PCXTimelineMapObject {

    <#
    .SYNOPSIS
        Creates a PCXLab.TimelineMap object from video segments.

    .DESCRIPTION
        Calculates the mathematical coordinate projection between the original source
        video timeline and the edited output timeline based on kept segments.

        Extracts kept intervals, cumulative timeline positions, total removed duration,
        and internal seam cut points on the edited timeline.

    .PARAMETER Segments
        One or more PCXLab.VideoSegment objects.

    .OUTPUTS
        PCXLab.TimelineMap
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [object[]]$Segments

    )

    $validSegments = foreach ($seg in $Segments) {
        if ($seg.PSTypeNames -notcontains 'PCXLab.VideoSegment') {
            throw 'InputObject must be a PCXLab.VideoSegment object.'
        }
        $seg
    }

    $sourcePath = $validSegments[0].SourcePath
    $uniqueSources = @($validSegments.SourcePath | Sort-Object -Unique)
    if ($uniqueSources.Count -gt 1) {
        throw "All video segments must belong to the same source. Found: $($uniqueSources -join ', ')."
    }

    # Sort all segments chronologically
    $sortedSegments = @($validSegments | Sort-Object StartSeconds)
    $keepSegments = @($sortedSegments | Where-Object Action -eq 'Keep')

    if ($keepSegments.Count -eq 0) {
        throw 'Cannot create timeline map: No Keep segments were found.'
    }

    $originalDuration = if ($sortedSegments.Count -gt 0) {
        $sortedSegments[-1].EndSeconds
    }
    else {
        0.0
    }

    $intervals = [System.Collections.Generic.List[object]]::new()
    $editedCuts = [System.Collections.Generic.List[double]]::new()
    $cumulativeEditedSeconds = 0.0

    for ($i = 0; $i -lt $keepSegments.Count; $i++) {

        $keep = $keepSegments[$i]
        $duration = [Math]::Round(($keep.EndSeconds - $keep.StartSeconds), 3)
        $editedStart = [Math]::Round($cumulativeEditedSeconds, 3)
        $editedEnd = [Math]::Round(($cumulativeEditedSeconds + $duration), 3)

        $intervals.Add([PSCustomObject]@{
            Index                = $i
            OriginalStartSeconds = $keep.StartSeconds
            OriginalEndSeconds   = $keep.EndSeconds
            EditedStartSeconds   = $editedStart
            EditedEndSeconds     = $editedEnd
            DurationSeconds      = $duration
        })

        $cumulativeEditedSeconds = $editedEnd

        # Seam cuts exist between adjacent kept segments (at editedEnd of all segments except the last)
        if ($i -lt ($keepSegments.Count - 1)) {
            $editedCuts.Add($editedEnd)
        }

    }

    $totalRemovedSeconds = [Math]::Round(($originalDuration - $cumulativeEditedSeconds), 3)
    if ($totalRemovedSeconds -lt 0) { $totalRemovedSeconds = 0.0 }

    [PSCustomObject]@{
        PSTypeName              = 'PCXLab.TimelineMap'
        SourcePath              = $sourcePath
        OriginalDurationSeconds = [Math]::Round($originalDuration, 3)
        EditedDurationSeconds   = [Math]::Round($cumulativeEditedSeconds, 3)
        TotalRemovedSeconds     = $totalRemovedSeconds
        Intervals               = @($intervals)
        EditedCutPointsSeconds  = @($editedCuts)
    }

}
