function Start-PCXProcess {

    <#
    .SYNOPSIS
        Executes an external process.

    .DESCRIPTION
        Executes an external executable, waits for completion,
        captures standard output and validates the exit code.

    .PARAMETER FilePath
        Full path to the executable.

    .PARAMETER ArgumentList
        Command-line arguments.

    .OUTPUTS
        System.String

    .NOTES
        Internal function.
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,

        [Parameter()]
        [string[]]$ArgumentList = @()

    )

    if (-not (Test-Path -LiteralPath $FilePath)) {

        throw "Executable not found: $FilePath"

    }

    $Output = & $FilePath @ArgumentList

    $ExitCode = $LASTEXITCODE

    if ($ExitCode -ne 0) {

        throw "Process '$FilePath' failed with exit code $ExitCode."

    }

    return ($Output -join [Environment]::NewLine)
}