function Resolve-PCXOutputPath {

    <#
    .SYNOPSIS
        Resolves the output file path for an export operation.

    .DESCRIPTION
        Returns the user-specified output path when provided. Otherwise,
        generates an output file in the source media directory using the
        specified output name and extension.

    .PARAMETER SourcePath
        The source media file.

    .PARAMETER OutputPath
        Optional output file path supplied by the caller.

    .PARAMETER OutputName
        Descriptive name appended to the source file name.

    .PARAMETER Extension
        Output file extension including the leading period.

    .EXAMPLE
        Resolve-PCXOutputPath `
            -SourcePath 'C:\Videos\Test.mp4' `
            -OutputName 'PremiereMarkers' `
            -Extension '.jsx'

        Returns:

            C:\Videos\Test-PremiereMarkers.jsx
    #>

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,

        [string]$OutputPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Extension

    )

    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        return $OutputPath
    }

    $directory = Split-Path -Path $SourcePath -Parent

    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($SourcePath)

    Join-Path $directory "$fileName-$OutputName$Extension"

}