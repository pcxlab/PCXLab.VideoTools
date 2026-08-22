Import-Module "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools" -Force

$Videos = Get-ChildItem "F:\Recording" -Recurse -File |
Where-Object {

    $_.DirectoryName -notmatch 'NOT WORKING' -and

    (
        $_.Name -match '^bandicam \d{4}-\d{2}-\d{2} \d{2}-\d{2}-\d{2}-\d+\.mp4$' -or
        $_.Name -match '^VID_\d{8}_\d{6}\.mp4$'
    ) -and

    $_.Name -notmatch '\.webcam\.mp4$' -and
    $_.Name -notmatch '\.webcam_fixed\.mp4$' -and
    $_.Name -notmatch '_fixed\.mp4$'

}

Write-Host ""
Write-Host "Videos found : $($Videos.Count)"
Write-Host ""

foreach ($Video in $Videos) {

    Write-Host "==================================================="
    Write-Host "Processing:"
    Write-Host $Video.FullName
    Write-Host "==================================================="

    try {

        #
        # Skip already processed videos
        #

        $AnalysisFile = Join-Path `
            $Video.DirectoryName `
        ("{0}-Analysis.json" -f [System.IO.Path]::GetFileNameWithoutExtension($Video.Name))

        if (Test-Path $AnalysisFile) {

            Write-Host "[SKIPPED] Already analyzed." -ForegroundColor Cyan
            continue

        }

        #
        # Analyze
        #

        $Analysis = Analyze-PCXVideo `
            -Path $Video.FullName

        #
        # Analysis Cache
        #

        $Analysis |
        Export-PCXVideoAnalysis -Force |
        Out-Null

        #
        # Silence
        #

        $Silence = $Analysis |
        Get-PCXSilence

        $Silence |
        Export-PCXSilence -Force |
        Out-Null

        #
        # Edit Points
        #

        $Silence |
        Get-PCXEditPoint |
        Export-PCXEditPoint -Force |
        Out-Null

        #
        # Video Segments
        #

        $Segments = $Silence |
        Get-PCXVideoSegments

        #
        # Premiere Markers
        #

        $Segments |
        Export-PCXPremiereMarkers |
        Out-Null

        #
        # Premiere Razor Script
        #

        $Segments |
        Export-PCXPremiereEditPoints |
        Out-Null

        Write-Host "[SUCCESS] $($Video.Name)" -ForegroundColor Green

    }
    catch {

        Write-Host "[FAILED ] $($Video.Name)" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Yellow

    }

}

Write-Host ""
Write-Host "======================================="
Write-Host "Finished processing all recordings."
Write-Host "======================================="