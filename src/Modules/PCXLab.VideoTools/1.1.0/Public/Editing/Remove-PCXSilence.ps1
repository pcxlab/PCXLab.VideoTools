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
            Get-PCXSetting `
                -Name 'Analysis.SilenceThreshold' `
                -DefaultValue -35
        ),

        [Parameter()]
        [double]$MinimumDuration = (
            Get-PCXSetting `
                -Name 'Analysis.MinimumSilenceDuration' `
                -DefaultValue 1
        )

    )

    process {

        if ([string]::IsNullOrWhiteSpace($OutputPath)) {

            $OutputPath = Get-PCXDefaultOutputPath `
                -SourcePath $Path `
                -Suffix 'Edited' `
                -Extension '.mp4'

        }

        $Segments = Find-PCXSilence `
            -Path $Path `
            -NoiseFloor $NoiseFloor `
            -MinimumDuration $MinimumDuration |
        Get-PCXVideoSegments

        if ($Segments.Count -eq 0) {
            throw 'No video segments were generated.'
        }

        $Filter = $Segments |
        ConvertTo-PCXConcatFilter `
            -InputIndex 0

        $Arguments = @(

            '-y'

            '-i'
            $Path

            '-filter_complex'
            $Filter

            '-map'
            '[outv]'

            '-map'
            '[outa]'

            '-c:v'
            'libx264'

            '-c:a'
            'aac'

            $OutputPath

        )



        Invoke-PCXFFmpeg `
            -ArgumentList $Arguments | Out-Null

        Get-Item $OutputPath

    }

}