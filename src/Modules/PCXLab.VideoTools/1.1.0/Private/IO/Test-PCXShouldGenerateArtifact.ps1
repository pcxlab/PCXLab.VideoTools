function Test-PCXShouldGenerateArtifact {

    <#
    .SYNOPSIS
        Determines whether an output artifact should be generated.

    .DESCRIPTION
        Centralizes the overwrite policy for all generated output files.

        - If the target path does not exist, generation should proceed.
        - If the target path exists and -Force is specified, generation should
          proceed.
        - If the target path exists and -Force is not specified, a skip message
          is displayed and generation should not proceed.

        This helper is intentionally simple. Future policies (timestamps, hashes,
        schema versions, etc.) can be added here without changing consumers.

    .PARAMETER Path
        Target output path for the artifact.

    .PARAMETER Force
        Overwrite an existing artifact.

    .OUTPUTS
        System.Boolean
    #>

    [CmdletBinding()]
    [OutputType([bool])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter()]
        [switch]$Force

    )

    if ($Force -or -not (Test-Path -LiteralPath $Path)) {
        return $true
    }

    Write-Host 'Artifact already exists.' -ForegroundColor Yellow
    Write-Host 'Skipping:' -ForegroundColor Yellow
    Write-Host "    $Path" -ForegroundColor Yellow
    Write-Host 'Use -Force to overwrite.' -ForegroundColor Yellow

    return $false

}
