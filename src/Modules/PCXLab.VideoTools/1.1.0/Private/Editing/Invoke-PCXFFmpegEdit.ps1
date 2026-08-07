function Invoke-PCXFFmpegEdit {

    <#
    .SYNOPSIS
        Executes an FFmpeg editing operation.

    .DESCRIPTION
        Builds the FFmpeg command line required to edit a media file
        using a supplied filter graph.

    .PARAMETER SourcePath
        Source media file.

    .PARAMETER OutputPath
        Destination media file.

    .PARAMETER Filter
        FFmpeg filter_complex string.

    .PARAMETER VideoCodec
        Video codec.

    .PARAMETER AudioCodec
        Audio codec.

    .OUTPUTS
        System.IO.FileInfo
    #>

    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param(

        [Parameter(Mandatory)]
        [ValidateScript({
                Test-Path $_ -PathType Leaf
            })]
        [string]$SourcePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Filter,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$VideoCodec = 'libx264',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$AudioCodec = 'aac',

        [Parameter()]
        [ValidateRange(0, 100)]
        [int]$InputIndex = 0

    )

    $Arguments = @(

        '-y'

        '-i'
        $SourcePath

        '-filter_complex'
        $Filter

        '-map'
        '[outv]'

        '-map'
        '[outa]'

        '-c:v'
        $VideoCodec

        '-c:a'
        $AudioCodec

        $OutputPath

    )

    Invoke-PCXFFmpeg `
        -ArgumentList $Arguments |
    Out-Null

    Get-Item $OutputPath

}