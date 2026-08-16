Import-Module "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools" -Force

# $Root = "F:\Recordings"
$Root = "C:\Recording seg TestONLOY"

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " PCXLab Recording Session Batch Processor" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Root Folder : $Root"
Write-Host ""

if (-not (Test-Path $Root)) {
    throw "Folder not found: $Root"
}

#
# Find every folder containing a Bandicam recording.
# These are considered recording-session folders.
#

$RecordingGroups = Get-ChildItem -Path $Root -Recurse -Directory | Where-Object {

    Get-ChildItem $_.FullName -File |
    Where-Object {
        $_.Name -match '^bandicam .*\.mp4$' -and
        $_.Name -notmatch '\.webcam\.mp4$'
    }

}

Write-Host "Recording Groups Found : $($RecordingGroups.Count)" -ForegroundColor Green
Write-Host ""

foreach ($Group in $RecordingGroups) {

    Write-Host ""
    Write-Host "===================================================" -ForegroundColor Cyan
    Write-Host "Processing Recording Session"
    Write-Host "===================================================" -ForegroundColor Cyan
    Write-Host $Group.FullName
    Write-Host ""

    #
    # Reference (Bandicam Screen)
    #

    $Reference = Get-ChildItem $Group.FullName -File |
    Where-Object {
        $_.Name -match '^bandicam .*\.mp4$' -and
        $_.Name -notmatch '\.webcam\.mp4$'
    } |
    Select-Object -First 1

    #
    # Webcam
    #

    $Webcam = Get-ChildItem $Group.FullName -File |
    Where-Object {
        $_.Name -match '\.webcam\.mp4$'
    } |
    Select-Object -First 1

    #
    # Nokia Phone Recording
    #

    $Phone = Get-ChildItem $Group.FullName -File |
    Where-Object {
        $_.Name -match '^VID_\d{8}_\d{6}\.mp4$'
    } |
    Select-Object -First 1

    #
    # Display files found
    #

    Write-Host "Reference : $($Reference.Name)"
    Write-Host "Webcam    : $($Webcam.Name)"
    Write-Host "Phone     : $($Phone.Name)"
    Write-Host ""

    #
    # Validate
    #

    if (-not $Reference) {

        Write-Warning "Skipping - Bandicam recording not found."
        continue
    }

    if (-not $Webcam) {

        Write-Warning "Skipping - Webcam recording not found."
        continue
    }

    if (-not $Phone) {

        Write-Warning "Skipping - Nokia recording not found."
        continue
    }

    try {

        Edit-PCXRecordingSession `
            -ReferencePath $Reference.FullName `
            -SourcePaths @(
                $Phone.FullName
                $Webcam.FullName
            ) `
            -OutputDirectory $Group.FullName

        Write-Host ""
        Write-Host "[SUCCESS] Recording session processed." -ForegroundColor Green

    }
    catch {

        Write-Host ""
        Write-Host "[FAILED]" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Yellow

    }
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host " Finished processing recording sessions."
Write-Host "=========================================" -ForegroundColor Green