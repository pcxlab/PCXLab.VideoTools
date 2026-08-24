function Get-PCXVideoSegments {

    <#
    .SYNOPSIS
        Builds video editing segments from analysis events or analysis containers.

    .DESCRIPTION
        Converts temporal analysis events (such as silence, black frames, or
        future analysis detections) or complete PCXLab.VideoAnalysis objects
        into PCXLab.VideoSegment objects representing both sections to keep
        and sections to remove.

    .PARAMETER InputObject
        One or more analysis event objects or a PCXLab.VideoAnalysis container
        received from the pipeline.

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

        if ($InputObject.PSTypeNames -contains 'PCXLab.VideoAnalysis') {

            if ($null -ne $InputObject.Analysis) {

                if ($null -ne $InputObject.Analysis.Silence) {
                    foreach ($e in @($InputObject.Analysis.Silence)) {
                        if (Test-PCXAnalysisEvent -InputObject $e) {
                            $Events.Add($e)
                        }
                    }
                }

                if ($null -ne $InputObject.Analysis.BlackFrames) {
                    foreach ($e in @($InputObject.Analysis.BlackFrames)) {
                        if (Test-PCXAnalysisEvent -InputObject $e) {
                            $Events.Add($e)
                        }
                    }
                }

            }

        }
        elseif (Test-PCXAnalysisEvent -InputObject $InputObject) {
            $Events.Add($InputObject)
        }
        else {
            throw "InputObject must be a PCXLab.VideoAnalysis object or a valid analysis event conforming to the PCXLab analysis event contract."
        }

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