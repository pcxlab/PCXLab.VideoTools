function Get-PCXOutputPath {

    <#
    .SYNOPSIS
        Resolves the output path for generated media.

    .DESCRIPTION
        Returns the final output path using the following priority:

        1. OutputPath
        2. OutputDirectory + configured suffix
        3. Source directory + configured suffix

    .PARAMETER SourcePath
        Source media file.

    .PARAMETER OutputDirectory
        Optional destination directory.

    .PARAMETER OutputPath
        Explicit output path.

    .OUTPUTS
        System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(

        [Parameter(Mandatory)]
        [ValidateScript({
                Test-Path -LiteralPath $_ -PathType Leaf
            })]
        [string]$SourcePath,

        [Parameter()]
        [string]$OutputDirectory,

        [Parameter()]
        [string]$OutputPath

    )

    #
    # Explicit output path always wins
    #

    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        return $OutputPath
    }

    #
    # Read configured suffix
    #

    $Suffix = Get-PCXSetting `
        -Name 'Output.Suffix' `
        -DefaultValue '-Edited'

    #
    # Build filename
    #

    $FileNameWithoutExtension =
    [System.IO.Path]::GetFileNameWithoutExtension($SourcePath)

    $Extension =
    [System.IO.Path]::GetExtension($SourcePath)

    $OutputFileName =
    "$FileNameWithoutExtension$Suffix$Extension"

    #
    # Resolve destination folder
    #

    if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {

        $OutputDirectory =
        Split-Path $SourcePath -Parent

    }

    return (Join-Path $OutputDirectory $OutputFileName)

}