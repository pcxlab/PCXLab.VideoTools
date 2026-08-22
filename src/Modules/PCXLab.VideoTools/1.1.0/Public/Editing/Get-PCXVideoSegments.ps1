function Get-PCXVideoSegments {

    <#
    .SYNOPSIS
        Builds video editing segments from analysis events.

    .DESCRIPTION
        Converts temporal analysis events (such as silence, black frames, or
        future analysis detections) into PCXLab.VideoSegment objects representing
        both sections to keep and sections to remove.

    .PARAMETER InputObject
        One or more analysis event objects received from the pipeline.
        Each event must conform to the PCXLab analysis event contract.

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
        [ValidateNotNull()]
        [object]$InputObject

    )

    begin {

        $Events = [System.Collections.Generic.List[object]]::new()

    }

    process {

        if (-not (Test-PCXAnalysisEvent -InputObject $InputObject)) {
            throw "InputObject must be a valid analysis event conforming to the PCXLab analysis event contract."
        }

        $Events.Add($InputObject)

    }

    end {

        $Segments = [System.Collections.Generic.List[object]]::new()

        if ($Events.Count -eq 0) {
            return
        }

        $uniqueSourcePaths = @($Events.SourcePath | Sort-Object -Unique)

        if ($uniqueSourcePaths.Count -gt 1) {
            throw "All input objects must belong to the same source. Found: $($uniqueSourcePaths -join ', ')."
        }

        $SourcePath = $Events[0].SourcePath

        $VideoDuration = Get-PCXVideoDuration `
            -Path $SourcePath

        $CurrentPosition = [TimeSpan]::Zero

        foreach ($Item in ($Events | Sort-Object Start)) {

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
                -End $Item.End

            if ($null -ne $Segment) {
                $Segments.Add($Segment)
            }

            $CurrentPosition = $Item.End

        }

        #
        # Final KEEP segment
        #

        if ($CurrentPosition -lt $VideoDuration) {

            $Segment = Add-PCXKeepSegment `
                -SourcePath $SourcePath `
                -Start $CurrentPosition `
                -End $VideoDuration

            if ($null -ne $Segment) {
                $Segments.Add($Segment)
            }

        }

        $Segments | 
            Optimize-PCXVideoSegments

    }

}