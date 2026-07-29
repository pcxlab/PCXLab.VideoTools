ffmpeg -i "C:\Videos\Tutorial.mp4" `
    -af silencedetect=noise=-35dB:d=2 `
    -f null -

C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools\1.1.0\Private\Providers\FFmpeg\

"C:\Projects\PCXLab.VideoTools\Tools\FFmpeg\bin\ffmpeg.exe"

.\Tools\FFmpeg\bin\ffmpeg.exe -i "C:\Projects\PCXLab.VideoTools\Tests\TestData\Test.mp4" `
    -af silencedetect=noise=-35dB:d=2 `
    -f null -

Clear-Host

Remove-Module PCXLab.VideoTools -Force
Import-Module .\src\Modules\PCXLab.VideoTools

Find-PCXSilence `
    -Path C:\Video.mp4 `
    -MinimumDuration 2 `
    -NoiseFloor -35


Import-Module .\src\Modules\PCXLab.VideoTools -Force

Find-PCXSilence `
    -Path 'C:\Videos\Test.mp4' `
    -MinimumDuration 2 `
    -NoiseFloor -35
    
Find-PCXSilence `
    -Path 'C:\Videos\Tutorial.mp4' `
    -MinimumDuration 2 `
    -NoiseFloor -35


Remove-Module PCXLab.VideoTools
Import-Module .\src\Modules\PCXLab.VideoTools # -Force

Find-PCXSilence -Path 'C:\Videos\Tutorial.mp4' |
Export-PCXPremiereMarkers `
    -OutputPath 'C:\Videos\Tutorial-SilenceMarkers.jsx' `
    -IncludeShortPause

############----------------------------------------------------------------
    
Find-PCXSilence -Path 'C:\Videos\Test.mp4' |
Export-PCXPremiereMarkers `
    -OutputPath 'C:\Videos\Tutorial-SilenceMarkers.jsx'

Find-PCXSilence -Path 'C:\Videos\Test.mp4' |
Export-PCXPremiereMarkers `
    -OutputPath 'C:\Videos\Tutorial-SilenceMarkersIncludeShortPause.jsx' `
    -IncludeShortPause

Find-PCXSilence -Path 'C:\Videos\Test.mp4' |
Export-PCXPremiereEditPoints `
    -OutputPath 'C:\Videos\Tutorial-EditPoints.jsx'

Find-PCXSilence -Path 'C:\Videos\Test.mp4' |
Export-PCXPremiereEditPoints `
    -OutputPath 'C:\Videos\Tutorial-EditPoints.jsx' 

Find-PCXSilence -Path 'C:\Videos\Test.mp4' |
Export-PCXPremiereEditPoints `
    -OutputPath 'C:\Videos\Tutorial-EditPointsAllTracks.jsx' `
    -AllTracks

Get-ChildItem -Recurse -Include *.ps1, *.psm1 |
Select-String "ConvertTo-PCXPremiereEditPointScript"

Convert-SecondsToTimecode 10.2

Get-ChildItem "$PSScriptRoot\Private" -Recurse -Filter *.ps1 |
ForEach-Object { . $_.FullName }


Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue

Import-Module .\src\Modules\PCXLab.VideoTools -Force

Get-Command ConvertTo-PCXPremiereTimecode

Get-Command -Module PCXLab.VideoTools

Get-Content "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools\1.1.0\Private\Premiere\ConvertTo-PCXPremiereTimecode.ps1"

Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue

Import-Module .\src\Modules\PCXLab.VideoTools -Force

Get-Command ConvertTo-PCXPremiereTimecode

Get-Command ConvertTo-PCXPremiereEditPointScript

git rm --cached Tools/FFmpeg/bin/ffmpeg.exe
git rm --cached Tools/FFmpeg/bin/ffplay.exe
git rm --cached Tools/FFmpeg/bin/ffprobe.exe

git commit -m "Stop tracking FFmpeg executables"

git rm --cached Tools/FFmpeg/bin/ffprobe.exe

git rm --cached Tests/TestData/Test.mp4

git commit -m "Stop tracking FFmpeg executables 1"

git log --stat --oneline origin/main..HEAD

#################################



