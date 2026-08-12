function New-PCXMediaSource {

    <#
    .SYNOPSIS
        Creates a PCXLab.MediaSource object for synchronization.

    .DESCRIPTION
        Builds a typed media-source descriptor from a media file path.
        Metadata is populated using the existing media-information pipeline.

    .PARAMETER Path
        Path to the source media file.

    .PARAMETER Id
        Optional stable identifier for the source.

    .PARAMETER Label
        Optional human-readable label.

    .PARAMETER Role
        Role of the source in the synchronized output.

    .PARAMETER SourceType
        Type of source media.

    .PARAMETER AudioStreamIndex
        Optional explicit audio stream index. -1 means Auto.

    .PARAMETER OffsetHint
        Optional hint about the expected offset in seconds.

    .OUTPUTS
        PCXLab.MediaSource
    #>

    [CmdletBinding()]
    [OutputType('PCXLab.MediaSource')]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('FullName')]
        [ValidateScript({
            Test-Path -LiteralPath $_ -PathType Leaf
        })]
        [string]$Path,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Label,

        [Parameter()]
        [ValidateSet(
            'Auto',
            'Primary',
            'Video',
            'Audio'
        )]
        [string]$Role = 'Auto',

        [Parameter()]
        [ValidateSet(
            'Auto',
            'Video',
            'Audio'
        )]
        [string]$SourceType = 'Auto',

        [Parameter()]
        [int]$AudioStreamIndex = -1,

        [Parameter()]
        [Nullable[double]]$OffsetHint

    )

    process {

        $resolvedPath = (Resolve-Path -LiteralPath $Path).Path

        $mediaInfo = Get-PCXMediaInformation -Path $resolvedPath

        if (-not $mediaInfo) {
            throw "Unable to retrieve media information for '$resolvedPath'."
        }

        if ([string]::IsNullOrWhiteSpace($Id)) {
            $Id = [System.IO.Path]::GetFileNameWithoutExtension($resolvedPath)
        }

        if ([string]::IsNullOrWhiteSpace($Label)) {
            $Label = [System.IO.Path]::GetFileName($resolvedPath)
        }

        New-PCXMediaSourceObject `
            -Path $resolvedPath `
            -Id $Id `
            -Label $Label `
            -Role $Role `
            -SourceType $SourceType `
            -AudioStreamIndex $AudioStreamIndex `
            -OffsetHint $OffsetHint `
            -MediaInformation $mediaInfo

    }

}
