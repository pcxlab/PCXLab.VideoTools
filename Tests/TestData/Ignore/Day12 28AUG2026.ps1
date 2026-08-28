Clear-Host

Remove-Module PCXLab.VideoTools -Force
Import-Module .\src\Modules\PCXLab.VideoTools -Force

Get-Module -Name PCXLab.VideoTools
Get-Command -Module PCXLab.VideoTools

Test-PCXVideoTools

#@#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

Import-PCXRecordingSession `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\RG_20260127_025337_004-RecordingSession.json" |
Select-Object -ExpandProperty Sources |
Select-Object Path, Role, SourceType


Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue
Import-Module .\src\Modules\PCXLab.VideoTools -Force


Invoke-PCXSynchronizedEditing `
    -ReferencePath "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST - Force\bandicam 2026-04-12 03-08-19-300.mp4" `
    -SourcePaths @(
    "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST - Force\VID_20260412_030812.mp4",
    "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST - Force\bandicam 2026-04-12 03-08-19-300.mp4.webcam.mp4"
)



Get-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST - 01\bandicam 2026-04-12 03-08-19-300.mp4" |
Get-PCXVideoSegments |
Edit-PCXVideoSegments




Invoke-Pester Tests

git diff --stat

git diff


