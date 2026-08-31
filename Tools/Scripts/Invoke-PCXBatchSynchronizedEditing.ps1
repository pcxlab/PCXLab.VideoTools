Import-Module "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools" -Force

#----------------------------------------------------------
# Configuration
#----------------------------------------------------------

$Root = "F:\Recordings"

# $Root = "C:\Recording seg TestONLOY"
# $Root = "C:\Recording seg TestONLOY\20260127 TEST Recording once\REC"

$Pipeline = "Synchronized Editing"

$Success = 0
$Failed = 0
$Skipped = 0

$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " PCXLab Batch Synchronized Editing"
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Root Folder : $Root"
Write-Host "Pipeline    : $Pipeline"
Write-Host ""

if (-not (Test-Path -LiteralPath $Root)) {
    throw "Folder not found: $Root"
}

#----------------------------------------------------------
# Discover Bandicam recordings
#----------------------------------------------------------

$Videos =
Get-ChildItem `
    -LiteralPath $Root `
    -Recurse `
    -File `
    -Filter "bandicam *.mp4" |
Where-Object {

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

        $SourcePaths = @()

        #
        # Webcam
        #

        $Webcam = "$($Video.FullName).webcam.mp4"

        if (Test-Path -LiteralPath $Webcam) {
            $SourcePaths += $Webcam
        }

        #
        # Phone
        #

        $Phone =
        Get-ChildItem `
            -LiteralPath $Video.DirectoryName `
            -File `
            -Filter "VID*.mp4" |
        Where-Object {

            $_.BaseName -notmatch '-Edited$'

        } |
        Sort-Object FullName |
        Select-Object -First 1

        if ($Phone) {
            $SourcePaths += $Phone.FullName
        }

        if ($SourcePaths.Count -eq 0) {

            Write-Warning "No source videos found."

            $Skipped++
            continue

        }

        Write-Host "Reference : $($Video.Name)"

        foreach ($Source in $SourcePaths) {

            Write-Host "Source    : $(Split-Path $Source -Leaf)"

        }

        Write-Host ""
        Write-Host "Synchronizing..." -ForegroundColor DarkCyan

        Invoke-PCXSynchronizedEditing `
            -ReferencePath $Video.FullName `
            -SourcePaths $SourcePaths

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
Write-Host " Batch Synchronized Editing Complete"
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