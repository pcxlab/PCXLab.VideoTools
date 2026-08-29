Import-Module "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools" -Force

$Videos = Get-ChildItem "C:\Recording" -Recurse -File |
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

    Write-Host ""
    Write-Host "==================================================="
    Write-Host "Processing:"
    Write-Host $Video.FullName
    Write-Host "==================================================="

    try {

        #
        # Skip if already edited
        #

        $EditedVideo = Join-Path `
            $Video.DirectoryName `
            ("{0}-Edited.mp4" -f [System.IO.Path]::GetFileNameWithoutExtension($Video.Name))

        if (Test-Path $EditedVideo) {

            Write-Host "[SKIPPED] Edited video already exists." -ForegroundColor Cyan
            continue

        }

        #
        # Remove Silence
        #

        Remove-PCXSilence `
            -Path $Video.FullName

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