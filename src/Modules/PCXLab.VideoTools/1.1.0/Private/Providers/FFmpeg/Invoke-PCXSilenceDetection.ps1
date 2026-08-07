function Invoke-PCXSilenceDetection {

    <#
    .SYNOPSIS
        Runs FFmpeg silence detection against a media file.

    .PARAMETER Path
        Path to the media file to analyse.

    .PARAMETER NoiseFloor
        Audio level at or below which audio is considered silence, in decibels.

    .PARAMETER MinimumDuration
        Minimum silence duration, in seconds.

    .OUTPUTS
        System.String

    .NOTES
        Internal function.
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]$Path,

        [Parameter()]
        [ValidateRange(-120, 0)]
        [double]$NoiseFloor = -35,

        [Parameter()]
        [ValidateRange(0.1, 3600)]
        [double]$MinimumDuration = 2

    )

    $filter = 'silencedetect=noise={0}dB:d={1}' -f $NoiseFloor, $MinimumDuration

    $Output = Invoke-PCXFFmpeg -ArgumentList @(
        '-hide_banner'
        '-nostats'
        '-i'
        $Path
        '-vn'
        '-af'
        $filter
        '-f'
        'null'
        '-'
    )

    $Output | Set-Content "$env:TEMP\PCXSilence.txt"

    return $Output
}
