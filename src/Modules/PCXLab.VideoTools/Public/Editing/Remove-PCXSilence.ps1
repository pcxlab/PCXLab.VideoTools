function Remove-PCXSilence {

    <#
.SYNOPSIS
    Removes silent sections from a video.

.DESCRIPTION
    Detects silence, builds an optimized timeline and creates
    a new edited video using FFmpeg.

.PARAMETER Path
    Source media file.

.PARAMETER OutputPath
    Destination media file.

.PARAMETER NoiseFloor
    Silence threshold in dB.

.PARAMETER MinimumDuration
    Minimum silence duration.

.OUTPUTS
    System.IO.FileInfo
#>

    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('FullName')]
        [ValidateScript({
                Test-Path $_ -PathType Leaf
            })]
        [string]$Path,

        [Parameter()]
        [string]$OutputPath,

        [Parameter()]
        [double]$NoiseFloor = (
            (Get-PCXAnalysisPolicy).Silence.NoiseFloor
        ),

        [Parameter()]
        [double]$MinimumDuration = (
            (Get-PCXAnalysisPolicy).Silence.MinimumDuration
        ),

        [Parameter()]
        [switch]$HorizontalFlip

    )

    process {

        Find-PCXSilence `
            -Path $Path `
            -NoiseFloor $NoiseFloor `
            -MinimumDuration $MinimumDuration |
        Get-PCXVideoSegments |
        Edit-PCXVideoSegments `
            -OutputPath $OutputPath `
            -HorizontalFlip:$HorizontalFlip

    }

}