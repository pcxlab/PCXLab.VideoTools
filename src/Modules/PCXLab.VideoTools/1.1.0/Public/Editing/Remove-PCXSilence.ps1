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

        #
        # Resolve output path
        #

        if ([string]::IsNullOrWhiteSpace($OutputPath)) {

            $OutputPath = Get-PCXDefaultOutputPath `
                -SourcePath $Path `
                -Suffix 'Edited' `
                -Extension '.mp4'

        }

        #
        # Build timeline
        #

        $Segments = Find-PCXSilence `
            -Path $Path `
            -NoiseFloor $NoiseFloor `
            -MinimumDuration $MinimumDuration |
        Get-PCXVideoSegments

        if ($Segments.Count -eq 0) {
            throw 'No video segments were generated.'
        }

        #
        # Build timeline filter graph
        #

        $FilterGraph = $Segments |
        ConvertTo-PCXConcatFilter `
            -InputIndex 0

        #
        # Read audio filter settings
        #

        $AudioSettings = [PSCustomObject]@{
            Normalize = Get-PCXSetting `
                -Name 'Audio.Normalize' `
                -DefaultValue $false

            Compression = Get-PCXSetting `
                -Name 'Audio.Compression' `
                -DefaultValue $false

            RepairChannels = Get-PCXSetting `
                -Name 'Audio.RepairChannels' `
                -DefaultValue $false
            }

        $AudioFilter = ConvertTo-PCXAudioFilter `
            -Settings $AudioSettings

        #
        # Merge audio filter into the filter graph
        #

        if (-not [string]::IsNullOrWhiteSpace($AudioFilter)) {

            $FilterGraph = $FilterGraph -replace '\[outa\]$', '[outa_pre]'

            $FilterGraph += ";[outa_pre]$AudioFilter[outa]"

        }

        #
        # Read source audio sample rate
        #

        $AudioInfo = Get-PCXAudioInformation -Path $Path

        $SampleRate = if ($AudioInfo -and $AudioInfo.SampleRate) {
            $AudioInfo.SampleRate
        } else {
            0
        }

        #
        # Create editing job
        #

        $Job = New-PCXEditJobObject `
            -SourcePath $Path `
            -OutputPath $OutputPath `
            -FilterGraph $FilterGraph `
            -SampleRate $SampleRate

        #
        # Execute job
        #

        Invoke-PCXFFmpegEdit `
            -EditJob $Job

    }

}