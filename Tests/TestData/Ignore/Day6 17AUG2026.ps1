
Clear-Host
Remove-Module PCXLab.VideoTools -Force
Import-Module .\src\Modules\PCXLab.VideoTools -Force

Get-Module -Name PCXLab.VideoTools
Get-Command -Module PCXLab.VideoTools

Test-PCXVideoTools

#@#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


$EditPoint = Get-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4" |
Find-PCXSilence |
Get-PCXEditPoint |
Select-Object -First 1

$EditPoint | Format-List *

"========== PSTypeNames =========="
$EditPoint.PSTypeNames

"========== Members =========="
$EditPoint | Get-Member

Edit-PCXRecordingSession `
    -ReferencePath "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4" `
    -SourcePaths @(
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4",
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4"
) `
    -OutputDirectory "C:\Recording seg TestONLOY"

git add .
git commit -m "Restore complete Edit-PCXRecordingSession pipeline and fix edit point generation"
git push

# Abovec functio nworked tested


Edit-PCXRecordingSession `
    -ReferencePath "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicamOriginal.mp4" `
    -SourcePaths @(
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337Original.mp4",
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcamOriginal.mp4"
) `
    -OutputDirectory "C:\Recording seg TestONLOY"