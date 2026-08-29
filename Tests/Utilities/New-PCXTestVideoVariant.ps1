Set-StrictMode -Version Latest

$script:FFmpeg = "C:\Projects\PCXLab.VideoTools\Tools\FFmpeg\bin\ffmpeg.exe"

function New-PCXTestVideoVariant {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [string]$Path,

        [ValidateSet(
            'Reference',
            'MediumQuality',
            'Repository',
            'VerySmall',
            'Tiny',
            'All'
        )]
        [string]$Variant = 'All',

        [switch]$Force
    )

    if (-not (Test-Path $script:FFmpeg)) {
        throw "FFmpeg not found: $script:FFmpeg"
    }

    if (-not (Test-Path $Path)) {
        throw "Path not found: $Path"
    }

    if ((Get-Item $Path) -is [System.IO.FileInfo]) {
        $files = @(Get-Item $Path)
    }
    else {
        $files = Get-ChildItem $Path -Filter *.mp4 -File
    }

    $presets = @{

        Reference = @{
            Prefix = 'A'
            Height = 768
            Crf    = 20
        }

        MediumQuality = @{
            Prefix = 'B'
            Height = 720
            Crf    = 26
        }

        Repository = @{
            Prefix = 'C'
            Height = 720
            Crf    = 32
        }

        VerySmall = @{
            Prefix = 'D'
            Height = 540
            Crf    = 36
        }

        Tiny = @{
            Prefix = 'E'
            Height = 360
            Crf    = 40
        }
    }

    if ($Variant -eq 'All') {
        $variants = $presets.Keys
    }
    else {
        $variants = @($Variant)
    }

    foreach ($file in $files) {

        $isWebcam = $file.Name -like '*.webcam.mp4'

        foreach ($variantName in $variants) {

            $preset = $presets[$variantName]

            $outputFile = Join-Path $file.DirectoryName (
                '{0}.{1}.{2}{3}' -f
                $file.BaseName,
                $preset.Prefix,
                $variantName,
                $file.Extension
            )

            if ((Test-Path $outputFile) -and -not $Force) {
                Write-Host "Skipping $($file.Name) ($variantName)"
                continue
            }

            Write-Host "Creating $([IO.Path]::GetFileName($outputFile))"

            $arguments = @(
                '-y'
                '-i'
                $file.FullName
                '-vf'
                "scale=-2:$($preset.Height)"
                '-c:v'
                'libx264'
                '-crf'
                $preset.Crf
                '-preset'
                'slow'
            )

            if ($isWebcam) {
                $arguments += '-an'
            }
            else {
                $arguments += '-c:a'
                $arguments += 'copy'
            }

            $arguments += $outputFile

            & $script:FFmpeg @arguments

            if ($LASTEXITCODE -ne 0) {
                throw "FFmpeg failed for $($file.Name)"
            }
        }
    }
}