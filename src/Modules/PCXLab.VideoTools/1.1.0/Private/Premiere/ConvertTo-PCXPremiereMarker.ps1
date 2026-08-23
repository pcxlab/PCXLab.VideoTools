function ConvertTo-PCXPremiereMarker {

    <#
    .SYNOPSIS
        Internal dispatcher that converts supported domain objects into normalized Premiere markers.

    .DESCRIPTION
        Inspects the input object type and routes it to the appropriate adapter:
        - PCXLab.VideoSegment -> Convert-PCXVideoSegmentToPremiereMarker
        - PCXLab.VideoAnalysis -> Unpacks constituent events -> Convert-PCXAnalysisEventToPremiereMarker
        - Analysis Events (conforming to Test-PCXAnalysisEvent) -> Convert-PCXAnalysisEventToPremiereMarker
        - PCXLab.PremiereMarker -> Returns unchanged

    .PARAMETER InputObject
        Domain object to convert into normalized Premiere marker(s).

    .OUTPUTS
        PCXLab.PremiereMarker
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()]
        [object]$InputObject

    )

    process {

        if ($InputObject.PSTypeNames -contains 'PCXLab.PremiereMarker') {
            $InputObject
        }
        elseif ($InputObject.PSTypeNames -contains 'PCXLab.VideoSegment') {
            Convert-PCXVideoSegmentToPremiereMarker -Segment $InputObject
        }
        elseif ($InputObject.PSTypeNames -contains 'PCXLab.VideoAnalysis') {

            if ($null -ne $InputObject.Analysis) {

                if ($null -ne $InputObject.Analysis.Silence) {
                    foreach ($event in @($InputObject.Analysis.Silence)) {
                        Convert-PCXAnalysisEventToPremiereMarker -Event $event
                    }
                }

                if ($null -ne $InputObject.Analysis.BlackFrames) {
                    foreach ($event in @($InputObject.Analysis.BlackFrames)) {
                        Convert-PCXAnalysisEventToPremiereMarker -Event $event
                    }
                }

            }

        }
        elseif (Test-PCXAnalysisEvent -InputObject $InputObject) {
            Convert-PCXAnalysisEventToPremiereMarker -Event $InputObject
        }
        else {
            throw "InputObject must be a PCXLab.VideoSegment, PCXLab.VideoAnalysis, or valid PCXLab Analysis Event. Received: $($InputObject.PSTypeNames[0])"
        }

    }

}

    