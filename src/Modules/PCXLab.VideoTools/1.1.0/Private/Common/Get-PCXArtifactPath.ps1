function Get-PCXArtifactPath {

    <#
    .SYNOPSIS
        Resolves the default path for a generated artifact.

    .DESCRIPTION
        Centralizes all artifact filename and path generation across the
        module. Each artifact type maps to suffix, extension, and
        separator metadata stored in a single shared catalog.

        Callers specify the artifact type and source path. An explicit
        OutputPath or OutputDirectory can still override the default name.

    .PARAMETER SourcePath
        Source media file used to derive the artifact location and base name.

    .PARAMETER ArtifactType
        Well-known artifact type. This determines suffix, extension, and
        separator rules from the shared catalog.

    .PARAMETER OutputPath
        Explicit output path. If specified, it is returned unchanged.

    .PARAMETER OutputDirectory
        Optional destination directory. If omitted, the source's directory
        is used.

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
        [ValidateSet(
            'Analysis',
            'Silence',
            'EditPoint',
            'VideoSegment',
            'RecordingSession',
            'PremiereMarker',
            'PremiereEditPoint',
            'EditedVideo'
        )]
        [string]$ArtifactType,

        [Parameter()]
        [string]$OutputPath,

        [Parameter()]
        [string]$OutputDirectory

    )

    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        return $OutputPath
    }

    $definitions = Get-PCXArtifactDefinitions
    $definition = $definitions[$ArtifactType]

    if ($null -eq $definition) {
        throw "Artifact type '$ArtifactType' is not defined in the artifact catalog."
    }

    if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
        $OutputDirectory = [System.IO.Path]::GetDirectoryName($SourcePath)
    }

    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($SourcePath)

    if ($definition.ContainsKey('ConfiguredSuffixSetting')) {

        $suffix = Get-PCXSetting `
            -Name $definition.ConfiguredSuffixSetting `
            -DefaultValue $definition.DefaultSuffix

        $extension = if ($null -eq $definition.Extension) {
            [System.IO.Path]::GetExtension($SourcePath)
        }
        else {
            $definition.Extension
        }

        $fileName = "$baseName$($definition.Separator)$suffix$extension"

    }
    else {

        if ($null -eq $definition.Suffix) {
            throw "Artifact type '$ArtifactType' has no suffix and no explicit filename rule."
        }

        $extension = if ($null -eq $definition.Extension) {
            [System.IO.Path]::GetExtension($SourcePath)
        }
        else {
            $definition.Extension
        }

        $prefix = ''

        if ($definition.ContainsKey('PrefixSource')) {

            switch ($definition.PrefixSource) {

                'DirectoryName' {
                    $prefix = [System.IO.Path]::GetFileName($OutputDirectory)
                }

            }

        }

        if ([string]::IsNullOrWhiteSpace($prefix)) {
            $fileName = "$baseName$($definition.Separator)$($definition.Suffix)$extension"
        }
        else {
            $fileName = "$prefix$($definition.Separator)$($definition.Suffix)$extension"
        }

    }

    return (Join-Path $OutputDirectory $fileName)

}
