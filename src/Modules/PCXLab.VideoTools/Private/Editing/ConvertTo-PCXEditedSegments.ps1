function ConvertTo-PCXEditedSegments {

    <#
    .SYNOPSIS
        Converts original keep segments to edited timeline coordinates.

    .DESCRIPTION
        Projects the supplied keep segments through an existing timeline map.
        Segments are emitted only when a corresponding kept interval exists in
        the map.

    .PARAMETER VideoSegments
        Original PCXLab.VideoSegment objects.

    .PARAMETER TimelineMap
        PCXLab.TimelineMap object for the edit.

    .OUTPUTS
        PCXLab.VideoSegment
    #>

    [CmdletBinding()]
    [OutputType('PCXLab.VideoSegment')]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [object[]]$VideoSegments,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$TimelineMap

    )

    if ($TimelineMap.PSTypeNames -notcontains 'PCXLab.TimelineMap') {
        throw 'TimelineMap must be a PCXLab.TimelineMap object.'
    }

    foreach ($segment in $VideoSegments) {

        if ($segment.PSTypeNames -notcontains 'PCXLab.VideoSegment') {
            throw 'VideoSegments must contain only PCXLab.VideoSegment objects.'
        }

        if ($segment.Action -ne 'Keep') {
            continue
        }

        $interval = @(
            $TimelineMap.Intervals |
                Where-Object {
                    $_.OriginalStartSeconds -eq $segment.StartSeconds -and
                    $_.OriginalEndSeconds -eq $segment.EndSeconds
                }
        ) | Select-Object -First 1

        if ($null -eq $interval) {
            throw "TimelineMap and VideoSegments are inconsistent. No matching TimelineMap interval was found for Keep segment '$($segment.SourcePath)' from $($segment.StartSeconds) to $($segment.EndSeconds) seconds."
        }

        New-PCXVideoSegmentObject `
            -SourcePath $TimelineMap.SourcePath `
            -Start ([TimeSpan]::FromSeconds($interval.EditedStartSeconds)) `
            -End ([TimeSpan]::FromSeconds($interval.EditedEndSeconds)) `
            -Action 'Keep' `
            -AnalysisEvents @($segment.AnalysisEvents)

    }

}
