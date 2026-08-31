Import-Module "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools" -Force

#----------------------------------------------------------
# Configuration
#----------------------------------------------------------

$Root = "F:\Recordings"
# $Root = "C:\Recording seg TestONLOY"
# $Root = "C:\Recording seg TestONLOY\20260127 TEST Recording once\REC"

$Pipeline = "Checkpoint-aware"

$Success = 0
$Failed = 0
$Skipped = 0

$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " PCXLab Standalone Video Batch Processor"
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Root Folder : $Root"
Write-Host "Pipeline    : $Pipeline"
Write-Host ""

if (-not (Test-Path -LiteralPath $Root)) {
    throw "Folder not found: $Root"
}

#----------------------------------------------------------
# Discover supported video files
#----------------------------------------------------------
<#
$Videos =
Get-ChildItem `
    -LiteralPath $Root `
    -Recurse `
    -File |
Where-Object {

    $_.Extension -match '^\.(mp4|mov|mkv|avi|m4v)$' -and
    $_.BaseName -notmatch '-Edited$'

} |
Sort-Object FullName
#>

# Webcam Excluded

$Videos =
Get-ChildItem `
    -LiteralPath $Root `
    -Recurse `
    -File |
Where-Object {

    $_.Extension -match '^\.(mp4|mov|mkv|avi|m4v)$' -and
    $_.BaseName -notmatch '-Edited$' -and
    $_.Name -notmatch '\.webcam\.'

} |
Sort-Object FullName

Write-Host "Videos Found : $($Videos.Count)" -ForegroundColor Green
Write-Host ""

$Index = 0

foreach ($Video in $Videos) {

    $Index++

    $VideoTimer = [System.Diagnostics.Stopwatch]::StartNew()

    Write-Host ""
    Write-Host "===================================================" -ForegroundColor Cyan
    Write-Host "Video [$Index / $($Videos.Count)]"
    Write-Host "===================================================" -ForegroundColor Cyan
    Write-Host $Video.FullName
    Write-Host ""

    try {

        #
        # Analysis
        #

        Write-Host "Generating / Loading Analysis..." -ForegroundColor DarkCyan

        $Analysis =
        Get-PCXVideoAnalysis `
            -Path $Video.FullName

        if (-not $Analysis) {

            Write-Warning "Analysis could not be generated."

            $Skipped++
            continue

        }

        #
        # VideoSegments
        #

        Write-Host "Generating / Loading VideoSegments..." -ForegroundColor DarkCyan

        $Segments = @(
            $Analysis |
            Get-PCXVideoSegments
        )

        if ($Segments.Count -eq 0) {

            Write-Warning "No VideoSegments were generated."

            $Skipped++
            continue

        }

        #
        # Common paths
        #

        $Folder = $Video.DirectoryName
        $BaseName = $Video.BaseName

        $AnalysisJson =
        Join-Path $Folder "$BaseName-Analysis.json"

        $VideoSegmentsJson =
        Join-Path $Folder "$BaseName-VideoSegments.json"

        $RemoveMarkersPath =
        Join-Path $Folder "$BaseName-RemoveMarkers.jsx"

        $RemoveEditPointsPath =
        Join-Path $Folder "$BaseName-RemoveEditPoints.jsx"

        #
        # Verify checkpoints
        #

        if (-not (Test-Path -LiteralPath $AnalysisJson)) {

            throw "Expected analysis checkpoint was not created:`n$AnalysisJson"

        }

        if (-not (Test-Path -LiteralPath $VideoSegmentsJson)) {

            throw "Expected VideoSegments checkpoint was not created:`n$VideoSegmentsJson"

        }

        #
        # Generate edited outputs
        #

        Write-Host "Generating edited artifacts..." -ForegroundColor DarkCyan

        $Segments |
        Edit-PCXVideoSegments |
        Out-Null

        #
        # Generate PremiereMarkers.jsx
        #

        Write-Host "Generating PremiereMarkers.jsx..." -ForegroundColor DarkCyan

        Import-PCXVideoSegment `
            -Path $VideoSegmentsJson |
        Export-PCXPremiereMarkers |
        Out-Null

        #
        # Generate PremiereEditPoints.jsx
        #

        Write-Host "Generating PremiereEditPoints.jsx..." -ForegroundColor DarkCyan

        Import-PCXVideoAnalysis `
            -Path $AnalysisJson |
        Get-PCXVideoSegments |
        Export-PCXPremiereEditPoints |
        Out-Null

        #
        # Generate RemoveMarkers.jsx
        #

        Write-Host "Generating RemoveMarkers.jsx..." -ForegroundColor DarkCyan

        Import-PCXVideoSegment `
            -Path $VideoSegmentsJson |
        Where-Object Action -eq 'Remove' |
        Export-PCXPremiereMarkers `
            -Path $RemoveMarkersPath |
        Out-Null

        #
        # Generate RemoveEditPoints.jsx
        #

        Write-Host "Generating RemoveEditPoints.jsx..." -ForegroundColor DarkCyan

        Import-PCXVideoAnalysis `
            -Path $AnalysisJson |
        Get-PCXVideoSegments |
        Where-Object Action -eq 'Remove' |
        Export-PCXPremiereEditPoints `
            -Path $RemoveEditPointsPath |
        Out-Null

        $VideoTimer.Stop()

        Write-Host ""
        Write-Host "[SUCCESS]" -ForegroundColor Green
        Write-Host ("Elapsed : {0}" -f $VideoTimer.Elapsed)

        $Success++

    }
    catch {

        $VideoTimer.Stop()

        Write-Host ""
        Write-Host "[FAILED]" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Yellow
        Write-Host ("Elapsed : {0}" -f $VideoTimer.Elapsed)

        $Failed++
    }

}

$Stopwatch.Stop()

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host " Standalone Video Batch Complete"
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

Write-Host ("Processed    : {0}" -f $Videos.Count)
Write-Host ("Success      : {0}" -f $Success) -ForegroundColor Green
Write-Host ("Failed       : {0}" -f $Failed) -ForegroundColor Red
Write-Host ("Skipped      : {0}" -f $Skipped) -ForegroundColor Yellow

if ($Videos.Count -gt 0) {

    $Rate = [math]::Round(
        ($Success / $Videos.Count) * 100,
        2
    )

    Write-Host ("Success Rate : {0} %" -f $Rate)

}

Write-Host ("Elapsed      : {0}" -f $Stopwatch.Elapsed)
Write-Host ""
