
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


Get-ChildItem "C:\Projects\PCXLab.VideoTools\src" -Recurse -Filter *.ps1 |
Select-String -Pattern '\$TranslatedEditPoints\s*=\s*\$ReferenceEditPoints'

$message = @"
refactor(synchronization): extract generic analysis event translation

- Add Convert-PCXAnalysisEventToSource helper
- Remove inline event translation from Edit-PCXRecordingSession
- Centralize analysis event synchronization logic
- Preserve the existing public API and workflow
- Add unit tests for generic event translation
"@

git commit -m $message
git push

