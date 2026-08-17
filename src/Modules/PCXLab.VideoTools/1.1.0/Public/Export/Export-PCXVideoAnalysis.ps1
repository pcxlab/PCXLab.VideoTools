function Export-PCXVideoAnalysis {

<#
.SYNOPSIS
    Exports a PCXLab.VideoAnalysis object to a JSON file.

.DESCRIPTION
    Saves the complete analysis of a media file so it can be reused
    without running Analyze-PCXVideo again.

    If -Path is not specified, a default output path is generated
    beside the source media file.

.PARAMETER InputObject
    PCXLab.VideoAnalysis object.

.PARAMETER Path
    Destination JSON file.

.PARAMETER Force
    Overwrite an existing file.

.EXAMPLE
    Analyze-PCXVideo -Path 'C:\Videos\Test.mp4' |
        Export-PCXVideoAnalysis

.EXAMPLE
    Analyze-PCXVideo -Path 'C:\Videos\Test.mp4' |
        Export-PCXVideoAnalysis `
            -Path 'C:\Cache\Test-Analysis.json'

.OUTPUTS
    System.IO.FileInfo
#>

[CmdletBinding(SupportsShouldProcess)]
[OutputType([System.IO.FileInfo])]
param(

    [Parameter(
        Mandatory,
        ValueFromPipeline
    )]
    [ValidateNotNull()]
    [object]$InputObject,

    [Parameter()]
    [Alias('OutputPath')]
    [ValidateNotNullOrEmpty()]
    [string]$Path,

    [switch]$Force

)

begin {

    $Analysis = [System.Collections.Generic.List[object]]::new()

}

process {

    if ($InputObject.PSTypeNames -notcontains 'PCXLab.VideoAnalysis') {
        throw 'InputObject must be a PCXLab.VideoAnalysis object.'
    }

    [void]$Analysis.Add($InputObject)

}

end {

    if ($Analysis.Count -eq 0) {
        throw 'No video analysis objects were provided.'
    }

    #
    # Default output path
    #

        if ([string]::IsNullOrWhiteSpace($Path)) {

            $Path = Get-PCXArtifactPath `
                -SourcePath $Analysis[0].SourcePath `
                -ArtifactType Analysis

        }

    #
    # Ensure output folder exists
    #

    $Parent = [System.IO.Path]::GetDirectoryName($Path)

    if ([string]::IsNullOrWhiteSpace($Parent)) {
        throw "Unable to determine parent folder from path '$Path'."
    }

    if (-not (Test-Path -LiteralPath $Parent)) {

        New-Item `
            -ItemType Directory `
            -Path $Parent `
            -Force | Out-Null

    }

    #
    # Build export document
    #

    $Document = New-PCXExportDocument `
        -CollectionName 'VideoAnalysis' `
        -Items $Analysis

    #
    # Export
    #

    if ($PSCmdlet.ShouldProcess($Path, 'Export video analysis')) {

        $Document |
            ConvertTo-Json -Depth 10 |
            Set-Content `
                -LiteralPath $Path `
                -Encoding UTF8 `
                -Force:$Force

        Get-Item -LiteralPath $Path

    }

}

}