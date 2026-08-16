
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