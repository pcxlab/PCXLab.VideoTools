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
    $_.Name -notmatch '_fixed\.mp4$' -and
    $_.Name -notmatch '-Edited\.mp4$' -and
    $_.Name -notmatch '_V\d+\.mp4$'
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
        # Today's output
        #

        $EditedVideo = Join-Path `
            $Video.DirectoryName `
            ("{0}-Edited.mp4" -f [System.IO.Path]::GetFileNameWithoutExtension($Video.Name))

        #
        # If today's output already exists, create V2
        # This allows us to keep multiple runs for comparison.
        #

        if (Test-Path $EditedVideo) {

            $BaseName = [System.IO.Path]::GetFileNameWithoutExtension($Video.Name)

            $Version = 2

            do {

                $EditedVideo = Join-Path `
                    $Video.DirectoryName `
                    ("{0}-Edited_V{1}.mp4" -f $BaseName, $Version)

                $Version++

            } while (Test-Path $EditedVideo)

            Write-Host "[INFO] Existing edited file found." -ForegroundColor Yellow
            Write-Host "[INFO] Today's output will be:" -ForegroundColor Yellow
            Write-Host "       $EditedVideo" -ForegroundColor Yellow
        }

        #
        # Remove Silence
        #

        Remove-PCXSilence `
            -Path $Video.FullName `
            -OutputPath $EditedVideo

        Write-Host "[SUCCESS] $($Video.Name)" -ForegroundColor Green
        Write-Host "[OUTPUT ] $EditedVideo" -ForegroundColor Green

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