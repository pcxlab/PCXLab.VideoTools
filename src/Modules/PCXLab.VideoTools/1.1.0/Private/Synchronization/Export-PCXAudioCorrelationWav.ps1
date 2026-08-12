function Export-PCXAudioCorrelationWav {

    <#
    .SYNOPSIS
        Extracts a low-rate mono WAV file for audio correlation.

    .DESCRIPTION
        Uses the existing FFmpeg provider to extract the selected audio
        stream as an 8 kHz, mono, 16-bit WAV file suitable for bounded
        cross-correlation.

    .PARAMETER Source
        PCXLab.MediaSource object.

    .PARAMETER OutputDirectory
        Directory where the WAV file will be written.

    .PARAMETER DurationSeconds
        Maximum duration to extract, in seconds. Default is 600.

    .OUTPUTS
        System.IO.FileInfo
    #>

    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Source,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputDirectory,

        [Parameter()]
        [ValidateRange(1, 3600)]
        [int]$DurationSeconds = 600

    )

    if ($Source.PSTypeNames -notcontains 'PCXLab.MediaSource') {
        throw 'Source must be a PCXLab.MediaSource object.'
    }

    $streamSelector = Get-PCXMediaSourceAudioStreamSelector -Source $Source

    $safeName = [System.IO.Path]::GetFileNameWithoutExtension($Source.Path)
    $invalidChars = [System.IO.Path]::GetInvalidFileNameChars() -join ''
    $invalidPattern = "[{0}]" -f [System.Text.RegularExpressions.Regex]::Escape($invalidChars)
    $safeName = $safeName -replace $invalidPattern, '_'

    $outputPath = Join-Path $OutputDirectory "$safeName-Correlation.wav"

    Invoke-PCXFFmpeg -ArgumentList @(
        '-y'
        '-i', $Source.Path
        '-map', $streamSelector
        '-vn'
        '-ar', '8000'
        '-ac', '1'
        '-sample_fmt', 's16'
        '-t', $DurationSeconds.ToString()
        $outputPath
    ) | Out-Null

    if (-not (Test-Path -LiteralPath $outputPath)) {
        throw "FFmpeg did not produce the expected WAV file: $outputPath"
    }

    return (Get-Item -LiteralPath $outputPath)

}
