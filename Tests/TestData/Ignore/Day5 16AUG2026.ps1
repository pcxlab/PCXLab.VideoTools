
Clear-Host

Remove-Module PCXLab.VideoTools -Force
Import-Module .\src\Modules\PCXLab.VideoTools -Force

Get-Module -Name PCXLab.VideoTools
Get-Command -Module PCXLab.VideoTools

Test-PCXVideoTools

#@#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Get-PCXSetting -Name "Analysis.EditPoints" | Format-List *

Get-PCXEditPointRule

$Silence = Get-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4" |
Find-PCXSilence |
Select-Object -First 1

$Silence | Format-List *

$Rule = Get-PCXEditPointRule `
    -Classification $Silence.Classification

$Rule | Format-List *

$EditPoint = $Silence | Get-PCXEditPoint -Verbose

$EditPoint | Format-List *


Get-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4" |
Find-PCXSilence |
Group-Object Classification |
Format-Table Name, Count