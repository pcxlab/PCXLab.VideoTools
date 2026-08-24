function Get-PCXEditedCutPoints {

    <#
    .SYNOPSIS
        Extracts seam cut points on the edited timeline.

    .DESCRIPTION
        Returns the timestamps (in seconds) corresponding to the internal join points
        between consecutive kept segments in an edited video.

        If there is 1 kept segment, 0 cut points are returned.
        If there are N kept segments, N - 1 cut points are returned.

    .PARAMETER TimelineMap
        A PCXLab.TimelineMap object.

    .PARAMETER Segments
        One or more PCXLab.VideoSegment objects. If provided, a timeline map is constructed.

    .OUTPUTS
        System.Double[]
    #>

    [CmdletBinding(DefaultParameterSetName = 'FromTimelineMap')]
    [OutputType([double[]])]
    param(

        [Parameter(Mandatory, ParameterSetName = 'FromTimelineMap', ValueFromPipeline)]
        [ValidateNotNull()]
        [object]$TimelineMap,

        [Parameter(Mandatory, ParameterSetName = 'FromSegments')]
        [ValidateNotNullOrEmpty()]
        [object[]]$Segments

    )

    process {

        $map = if ($PSCmdlet.ParameterSetName -eq 'FromSegments') {
            New-PCXTimelineMapObject -Segments $Segments
        }
        else {
            if ($TimelineMap.PSTypeNames -notcontains 'PCXLab.TimelineMap') {
                throw 'TimelineMap must be a PCXLab.TimelineMap object.'
            }
            $TimelineMap
        }

        return @($map.EditedCutPointsSeconds)

    }

}
