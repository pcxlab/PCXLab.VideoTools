function Get-PCXOutputPath {

    <#
    .SYNOPSIS
        Resolves the output path for generated media.

    .DESCRIPTION
        This function is retained for backward compatibility. It now
        delegates to Get-PCXArtifactPath for the EditedVideo artifact type.

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

    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        return $OutputPath
    }

    return Get-PCXArtifactPath `
        -SourcePath $SourcePath `
        -ArtifactType EditedVideo `
        -OutputDirectory $OutputDirectory

}
