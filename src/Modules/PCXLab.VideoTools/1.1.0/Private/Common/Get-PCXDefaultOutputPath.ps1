function Get-PCXDefaultOutputPath {

    <#
    .SYNOPSIS
        Generates a default output path for exported files.

    .DESCRIPTION
        Builds a default output filename based on the source media file,
        a suffix and a file extension.

    .PARAMETER SourcePath
        Source media file.

    .PARAMETER Suffix
        Suffix appended to the source filename.

    .PARAMETER Extension
        Output file extension. May be specified with or without a leading '.'.

    .EXAMPLE
        Get-PCXDefaultOutputPath `
            -SourcePath 'C:\Videos\Test.mp4' `
            -Suffix 'EditPoints' `
            -Extension '.json'

        Returns:
            C:\Videos\Test-EditPoints.json

    .OUTPUTS
        System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Suffix,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Extension

    )

    if ($Extension[0] -ne '.') {
        $Extension = ".$Extension"
    }

    $Directory = Split-Path $SourcePath -Parent
    $FileName = [System.IO.Path]::GetFileNameWithoutExtension($SourcePath)

    return (Join-Path $Directory "$FileName-$Suffix$Extension")

}