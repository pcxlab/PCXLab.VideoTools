function Select-PCXEditBoundaries {

    <#
    .SYNOPSIS
        Builds raw Keep and Remove video segments from temporal analysis events.

    .DESCRIPTION
        Processes temporal analysis events (such as silence or black frame detections)
        and interleaves Keep and Remove segments across the full video duration
        using a gap-fill algorithm.

    .PARAMETER Events
        One or more analysis event objects conforming to the analysis event contract.

    .PARAMETER SourcePath
        The path of the source media file.

    .PARAMETER Duration
        Total duration of the media file.

    .OUTPUTS
        PCXLab.VideoSegment
    #>

    [CmdletBinding()]
    [OutputType('PCXLab.VideoSegment')]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [AllowEmptyCollection()]
        [object[]]$Events,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [TimeSpan]$Duration

    )

    begin {

        $AllEvents = [System.Collections.Generic.List[object]]::new()

    }

    process {

        if ($null -ne $Events) {
            foreach ($item in $Events) {
                if ($null -ne $item) {
                    $AllEvents.Add($item)
                }
            }
        }

    }

    end {

        $Segments = [System.Collections.Generic.List[object]]::new()

        $CurrentPosition = [TimeSpan]::Zero

        foreach ($Item in ($AllEvents | Sort-Object Start)) {

            #
            # KEEP
            #

            if ($Item.Start -gt $CurrentPosition) {

                $Segment = Add-PCXKeepSegment `
                    -SourcePath $SourcePath `
                    -Start $CurrentPosition `
                    -End $Item.Start

                if ($null -ne $Segment) {
                    $Segments.Add($Segment)
                }

            }

            #
            # REMOVE
            #

            $Segment = Add-PCXRemoveSegment `
                -SourcePath $SourcePath `
                -Start $Item.Start `
                -End $Item.End `
                -AnalysisEvents @($Item)

            if ($null -ne $Segment) {
                $Segments.Add($Segment)
            }

            $CurrentPosition = $Item.End

        }

        #
        # Final KEEP segment
        #

        if ($CurrentPosition -lt $Duration) {

            $Segment = Add-PCXKeepSegment `
                -SourcePath $SourcePath `
                -Start $CurrentPosition `
                -End $Duration

            if ($null -ne $Segment) {
                $Segments.Add($Segment)
            }

        }

        $Segments

    }

}
