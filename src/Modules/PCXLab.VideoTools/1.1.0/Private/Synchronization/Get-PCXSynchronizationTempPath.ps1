function Get-PCXSynchronizationTempPath {

    <#
    .SYNOPSIS
        Returns a temporary directory for synchronization artifacts.

    .DESCRIPTION
        Creates and returns a module-owned temporary directory under the
        system TEMP path. Callers are responsible for cleaning up the
        contents.

    .OUTPUTS
        System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param()

    $TempRoot = Join-Path `
        ([System.IO.Path]::GetTempPath()) `
        'PCXLab\VideoTools\Synchronization'

    if (-not (Test-Path -LiteralPath $TempRoot)) {
        [void][System.IO.Directory]::CreateDirectory($TempRoot)
    }

    $Timestamp = (Get-Date -Format 'yyyyMMdd-HHmmss-fff')
    $SessionPath = Join-Path $TempRoot $Timestamp

    if (-not (Test-Path -LiteralPath $SessionPath)) {
        [void][System.IO.Directory]::CreateDirectory($SessionPath)
    }

    return $SessionPath

}
