function Import-PCXVideoAnalysis {

<#
.SYNOPSIS
    Imports a PCXLab.VideoAnalysis object from JSON.

.DESCRIPTION
    Imports a previously exported video analysis document and
    restores all PCXLab custom types.

.PARAMETER Path
    Path to a VideoAnalysis JSON file.

.EXAMPLE
    Import-PCXVideoAnalysis `
        -Path 'C:\Videos\Test-Analysis.json'

.OUTPUTS
    PCXLab.VideoAnalysis
#>

[CmdletBinding()]
[OutputType('PCXLab.VideoAnalysis')]
param(

    [Parameter(
        Mandatory,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
    )]
    [Alias('FullName')]
    [ValidateNotNullOrEmpty()]
    [string[]]$Path

)

process {

    foreach ($File in $Path) {

        if (-not (Test-Path -LiteralPath $File)) {
            throw "File not found: $File"
        }

        $Document = Get-Content `
            -LiteralPath $File `
            -Raw |
            ConvertFrom-Json

        if ($null -eq $Document.VideoAnalysis) {
            throw "File '$File' is not a PCXLab.VideoAnalysis export."
        }

        foreach ($Analysis in $Document.VideoAnalysis) {

            Restore-PCXVideoAnalysisTypes `
                -InputObject $Analysis

        }

    }

}

}