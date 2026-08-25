function Get-PCXSilence {

    <#
.SYNOPSIS
    Returns silence objects from a video analysis.

.DESCRIPTION
    Extracts the silence collection from a
    PCXLab.VideoAnalysis object.

.PARAMETER InputObject
    PCXLab.VideoAnalysis object.

.EXAMPLE
    Analyze-PCXVideo -Path 'C:\Videos\Test.mp4' |
        Get-PCXSilence

.OUTPUTS
    PCXLab.Silence
#>

    [CmdletBinding()]
    [OutputType('PCXLab.Silence')]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [ValidateNotNull()]
        [object]$InputObject

    )

    process {

        if ($InputObject.PSTypeNames -notcontains 'PCXLab.VideoAnalysis') {
            throw 'InputObject must be a PCXLab.VideoAnalysis object.'
        }

        if ($null -eq $InputObject.Analysis) {
            throw 'Video analysis does not contain an Analysis property.'
        }

        if ($null -eq $InputObject.Analysis.Silence) {
            return
        }

        $InputObject.Analysis.Silence
    }

}