Set-StrictMode -Version Latest

$script:FFmpeg = "C:\Projects\PCXLab.VideoTools\Tools\FFmpeg\bin\ffmpeg.exe"

function New-TestVideoVariant {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [string]$Path,

        [ValidateSet(
            'All',
            'Reference',
            'MediumQuality',
            'Repository',
            'VerySmall',
            'Tiny'
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
        $files = Get-ChildItem $Path -File -Filter *.mp4 |
                 Where-Object {
                    $_.BaseName -notmatch '\.(A|B|C|D|E)\.' -and
                    $_.BaseName -notmatch '_\d+min\.(A|B|C|D|E)\.'
                 }
    }

    $presets = @{

        Reference = @{
            Prefix = 'A'
            Height = 768
            CRF = 20
        }

        MediumQuality = @{
            Prefix = 'B'
            Height = 720
            CRF = 26
        }

        Repository = @{
            Prefix = 'C'
            Height = 720
            CRF = 32
        }

        VerySmall = @{
            Prefix = 'D'
            Height = 540
            CRF = 36
        }

        Tiny = @{
            Prefix = 'E'
            Height = 360
            CRF = 40
        }
    }

    if ($Variant -eq 'All') {
        $variants = @(
            'Reference',
            'MediumQuality',
            'Repository',
            'VerySmall',
            'Tiny'
        )
    }
    else {
        $variants = @($Variant)
    }

    foreach ($file in $files) {

        $isWebcam = $file.Name.EndsWith(".webcam.mp4")

        foreach ($variantName in $variants) {

            $preset = $presets[$variantName]

            #
            # Create variant folder
            #

            $variantFolder = Join-Path $file.DirectoryName (
                "$($preset.Prefix).$variantName"
            )

            New-Item `
                -ItemType Directory `
                -Path $variantFolder `
                -Force | Out-Null

            #
            # Output file
            #

            $outputFile = Join-Path $variantFolder (
                "{0}.{1}.{2}{3}" -f
                $file.BaseName,
                $preset.Prefix,
                $variantName,
                $file.Extension
            )

            if ((Test-Path $outputFile) -and -not $Force) {

                Write-Host "[Skip] $outputFile"

                continue
            }

            Write-Host "[Create] $outputFile"

            $arguments = @(
                '-y'
                '-i'
                $file.FullName
                '-vf'
                "scale=-2:$($preset.Height)"
                '-c:v'
                'libx264'
                '-crf'
                $preset.CRF
                '-preset'
                'slow'
            )

            if ($isWebcam) {
                $arguments += '-an'
            }
            else {
                $arguments += @(
                    '-c:a'
                    'copy'
                )
            }

            $arguments += $outputFile

            & $script:FFmpeg @arguments

            if ($LASTEXITCODE -ne 0) {
                throw "FFmpeg failed while processing '$($file.Name)'."
            }
        }
    }
}