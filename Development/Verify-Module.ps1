<#
    .SYNOPSIS
        Verifies the integrity of the PCXLab.VideoTools module.

    .DESCRIPTION
        Performs a series of development validation checks before code is
        committed or released.

        Current checks:

            • PowerShell syntax validation
            • Module import validation

        Future versions may include:

            • PSScriptAnalyzer
            • Pester
            • Manifest validation
            • Formatting checks
            • Build verification
#>

[CmdletBinding()]
param(

    [string]$ModuleRoot = (
        Join-Path $PSScriptRoot '..\src\Modules\PCXLab.VideoTools'
    )

)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " PCXLab.VideoTools Verification" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

#
# Verify all PowerShell source files.
#

Write-Host "[1/2] Checking PowerShell syntax..." -ForegroundColor Yellow

$files = Get-ChildItem `
    -Path $ModuleRoot `
    -Recurse `
    -Include *.ps1, *.psm1

$syntaxErrors = @()

foreach ($file in $files) {

    $tokens = $null
    $errors = $null

    [System.Management.Automation.Language.Parser]::ParseFile(
        $file.FullName,
        [ref]$tokens,
        [ref]$errors
    ) | Out-Null

    if ($errors.Count -gt 0) {

        foreach ($error in $errors) {

            $syntaxErrors += [PSCustomObject]@{
                File    = $file.FullName
                Line    = $error.Extent.StartLineNumber
                Column  = $error.Extent.StartColumnNumber
                Message = $error.Message
            }

        }

    }

}

if ($syntaxErrors.Count -eq 0) {

    Write-Host "  ✓ Syntax validation passed." -ForegroundColor Green

}
else {

    Write-Host ""
    Write-Host "Syntax errors detected." -ForegroundColor Red
    Write-Host ""

    $syntaxErrors |
        Format-Table -AutoSize

    throw "Syntax validation failed."

}

#
# Verify module imports.
#

Write-Host ""
Write-Host "[2/2] Importing module..." -ForegroundColor Yellow

$manifest = Join-Path $ModuleRoot 'PCXLab.VideoTools.psd1'

Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue

Import-Module $manifest -Force

Write-Host "  ✓ Module imported successfully." -ForegroundColor Green

#
# Success
#

Write-Host ""
Write-Host "==============================================" -ForegroundColor Green
Write-Host " Verification completed successfully." -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
Write-Host ""