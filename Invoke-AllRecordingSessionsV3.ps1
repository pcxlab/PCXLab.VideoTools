Import-Module "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools" -Force

 $Root = "F:\Recordings"
 #$Root = "C:\Recording seg TestONLOY"

$Success = 0
$Failed = 0
$Skipped = 0

$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " PCXLab Recording Session Batch Processor" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Root Folder : $Root"
Write-Host ""

if (-not (Test-Path -LiteralPath $Root)) {
    throw "Folder not found: $Root"
}

#
# Find every recording-session folder.
#

$RecordingGroups = Get-ChildItem `
    -Path $Root `
    -Recurse `
    -Directory |
Sort-Object FullName |
Where-Object {

    Get-ChildItem $_.FullName -File |
    Where-Object {

        $_.BaseName -notmatch '-Edited$' -and
        (
            $_.Name -ieq 'bandicam.mp4' -or
            (
                $_.Name -match '^bandicam .*\.mp4$' -and
                $_.Name -notmatch '\.webcam\.mp4$'
            )
        )

    }

}

Write-Host "Recording Groups Found : $($RecordingGroups.Count)" -ForegroundColor Green
Write-Host ""

$Index = 0

foreach ($Group in $RecordingGroups) {

    $Index++

    $SessionTimer = [System.Diagnostics.Stopwatch]::StartNew()

    Write-Host ""
    Write-Host "===================================================" -ForegroundColor Cyan
    Write-Host "Recording Session [$Index / $($RecordingGroups.Count)]"
    Write-Host "===================================================" -ForegroundColor Cyan
    Write-Host $Group.FullName
    Write-Host ""

    #
    # Reference Recording
    #

    $Reference = Get-ChildItem $Group.FullName -File |
    Where-Object {

        $_.BaseName -notmatch '-Edited$' -and
        (
            $_.Name -ieq 'bandicam.mp4' -or
            (
                $_.Name -match '^bandicam .*\.mp4$' -and
                $_.Name -notmatch '\.webcam\.mp4$'
            )
        )

    } |
    Select-Object -First 1

    #
    # Webcam Recording
    #

    $Webcam = Get-ChildItem $Group.FullName -File |
    Where-Object {

        $_.BaseName -notmatch '-Edited$' -and
        $_.Name -match '\.webcam\.mp4$'

    } |
    Select-Object -First 1

    #
    # Phone Recording
    #

    $Phone = Get-ChildItem $Group.FullName -File |
    Where-Object {

        $_.BaseName -notmatch '-Edited$' -and
        $_.Name -match '^VID_\d{8}_\d{6}\.mp4$'

    } |
    Select-Object -First 1

    #
    # Validate
    #

    if (-not $Reference) {

        Write-Warning "Reference recording not found."
        $Skipped++
        continue

    }

    if (-not $Webcam) {

        Write-Warning "Webcam recording not found."
        $Skipped++
        continue

    }

    if (-not $Phone) {

        Write-Warning "Phone recording not found."
        $Skipped++
        continue

    }

    Write-Host "Reference : $($Reference.Name)"
    Write-Host "Webcam    : $($Webcam.Name)"
    Write-Host "Phone     : $($Phone.Name)"
    Write-Host ""

    Write-Host "Executing:" -ForegroundColor Cyan

    @"
Edit-PCXRecordingSession `
    -ReferencePath "$($Reference.FullName)" `
    -SourcePaths @(
        "$($Phone.FullName)",
        "$($Webcam.FullName)"
    )
"@ | Write-Host

    Write-Host ""

    try {

        Edit-PCXRecordingSession `
            -ReferencePath $Reference.FullName `
            -SourcePaths @(
            $Phone.FullName
            $Webcam.FullName
        )

        $SessionTimer.Stop()

        Write-Host ""
        Write-Host "[SUCCESS]" -ForegroundColor Green
        Write-Host ("Elapsed : {0}" -f $SessionTimer.Elapsed)

        $Success++

    }
    catch {

        $SessionTimer.Stop()

        Write-Host ""
        Write-Host "[FAILED]" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Yellow
        Write-Host ("Elapsed : {0}" -f $SessionTimer.Elapsed)

        $Failed++

    }

}

$Stopwatch.Stop()

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host " Batch Processing Complete"
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

Write-Host ("Processed    : {0}" -f $RecordingGroups.Count)
Write-Host ("Success      : {0}" -f $Success) -ForegroundColor Green
Write-Host ("Failed       : {0}" -f $Failed) -ForegroundColor Red
Write-Host ("Skipped      : {0}" -f $Skipped) -ForegroundColor Yellow

if ($RecordingGroups.Count -gt 0) {

    $Rate = [math]::Round(($Success / $RecordingGroups.Count) * 100, 2)
    Write-Host ("Success Rate : {0} %" -f $Rate)

}

Write-Host ("Elapsed      : {0}" -f $Stopwatch.Elapsed)
Write-Host ""