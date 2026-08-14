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

    .PARAMETER FileName
        Optional fixed filename. When specified, the source filename is not
        used and the output is placed in the same folder as the source with
        the given name.

    .EXAMPLE
        Get-PCXDefaultOutputPath `
            -SourcePath 'C:\Videos\Test.mp4' `
            -Suffix 'EditPoints' `
            -Extension '.json'

        Returns:
            C:\Videos\Test-EditPoints.json

    .EXAMPLE
        Get-PCXDefaultOutputPath `
            -SourcePath 'C:\Videos\Test.mp4' `
            -FileName 'RecordingSession.json'

        Returns:
            C:\Videos\RecordingSession.json

    .OUTPUTS
        System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,

        [Parameter(
            Mandatory,
            ParameterSetName = 'BySuffix'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Suffix,

        [Parameter(
            Mandatory,
            ParameterSetName = 'BySuffix'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Extension,

        [Parameter(
            Mandatory,
            ParameterSetName = 'ByFileName'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$FileName

    )

    if ([string]::IsNullOrWhiteSpace($FileName)) {

        if ([string]::IsNullOrWhiteSpace($Extension)) {
            throw 'Extension is required when FileName is not specified.'
        }

        if ([string]::IsNullOrWhiteSpace($Suffix)) {
            throw 'Suffix is required when FileName is not specified.'
        }

        if ($Extension[0] -ne '.') {
            $Extension = ".$Extension"
        }

        $FileName = "$([System.IO.Path]::GetFileNameWithoutExtension($SourcePath))-$Suffix$Extension"

    }

    $Directory = Split-Path $SourcePath -Parent

    return (Join-Path $Directory $FileName)

}