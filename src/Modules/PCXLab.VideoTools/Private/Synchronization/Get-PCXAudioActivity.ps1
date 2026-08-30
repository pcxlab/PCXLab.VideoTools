function Get-PCXAudioActivity {

    <#
    .SYNOPSIS
        Extracts raw audio activity timeline from a video file.

    .DESCRIPTION
        Extracts audio from a video or audio file using FFmpeg, analyzes the
        audio into fixed-duration frames, and computes raw frame energy to
        produce an extensible audio activity timeline object for Stage 1
        synchronization.

    .PARAMETER Path
        Path to the media file.

    .PARAMETER FrameDuration
        Duration of each frame in seconds. Default is 0.01 (10ms).

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Internal helper for Stage 1 synchronization.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]$Path,

        [Parameter()]
        [ValidateRange(0.001, 10.0)]
        [double]$FrameDuration = 0.01

    )

    Write-Verbose "Analyzing audio activity for '$Path' with frame duration ${FrameDuration}s."

    $audioInfo = Get-PCXAudioInformation -Path $Path
    if ($null -eq $audioInfo -or -not $audioInfo.HasAudio) {
        throw "The file '$Path' does not contain an audio stream."
    }

    $tempDir = Get-PCXSynchronizationTempPath
    $safeName = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    $invalidChars = [System.IO.Path]::GetInvalidFileNameChars() -join ''
    $invalidPattern = "[{0}]" -f [System.Text.RegularExpressions.Regex]::Escape($invalidChars)
    $safeName = $safeName -replace $invalidPattern, '_'
    $tempWavPath = Join-Path $tempDir "$safeName-Activity-$([System.Guid]::NewGuid().ToString('N')).wav"

    $audioSampleRate = 8000

    try {

        Invoke-PCXFFmpeg -ArgumentList @(
            '-y'
            '-i', $Path
            '-map', '0:a:0'
            '-vn'
            '-ar', $audioSampleRate.ToString()
            '-ac', '1'
            '-sample_fmt', 's16'
            $tempWavPath
        ) | Out-Null

        if (-not (Test-Path -LiteralPath $tempWavPath)) {
            throw "FFmpeg failed to extract audio to expected path: $tempWavPath"
        }

        $samples = Read-PCXMonoWavSampleBlock `
            -Path $tempWavPath `
            -SampleRate $audioSampleRate `
            -StartSeconds 0 `
            -DurationSeconds 3600

        if ($null -eq $samples -or $samples.Length -eq 0) {
            throw "Extracted audio file contains no sample data: $Path"
        }

        $samplesPerFrame = [int][Math]::Round($audioSampleRate * $FrameDuration)
        if ($samplesPerFrame -lt 1) {
            throw "FrameDuration $FrameDuration is too small for audio sample rate $audioSampleRate."
        }

        $frameCount = [int][Math]::Floor($samples.Length / $samplesPerFrame)
        if ($frameCount -le 0) {
            throw "Audio duration is shorter than a single frame duration."
        }

        $frameRate = [int][Math]::Round(1.0 / $FrameDuration)
        $frames = [System.Collections.Generic.List[object]]::new($frameCount)

        for ($i = 0; $i -lt $frameCount; $i++) {

            $frameStart = $i * $samplesPerFrame
            $sumSquares = 0.0

            for ($j = 0; $j -lt $samplesPerFrame; $j++) {
                $normalizedSample = $samples[$frameStart + $j] / 32768.0
                $sumSquares += $normalizedSample * $normalizedSample
            }

            $energy = [Math]::Round([Math]::Sqrt($sumSquares / $samplesPerFrame), 6)
            $time = [Math]::Round($i * $FrameDuration, 6)

            $frames.Add([PSCustomObject]@{
                Time   = $time
                Energy = $energy
            })

        }

        Write-Verbose "Extracted $frameCount audio frames at $frameRate Hz frame rate."

        return [PSCustomObject]@{
            FrameRate       = $frameRate
            FrameDuration   = $FrameDuration
            AudioSampleRate = $audioSampleRate
            Frames          = $frames.ToArray()
        }

    }
    finally {

        if (Test-Path -LiteralPath $tempWavPath) {
            Remove-Item -LiteralPath $tempWavPath -Force -ErrorAction SilentlyContinue
        }

        if (Test-Path -LiteralPath $tempDir) {
            Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }

    }

}
