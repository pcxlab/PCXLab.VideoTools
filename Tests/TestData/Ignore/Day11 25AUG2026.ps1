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

git add .

$message = @"
ADR-0009 as complete.
"@

git commit -m $message
git push

Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue
Import-Module .\src\Modules\PCXLab.VideoTools -Force


Get-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300.mp4" |
Get-PCXVideoSegments |
Edit-PCXVideoSegments


#### With details
Import-PCXVideoSegment `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300-VideoSegments.json" |
Export-PCXPremiereMarkers -Force

Import-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300-Analysis.json" |
Get-PCXVideoSegments |
Export-PCXPremiereEditPoints -Force

#### With only remve filtered

Import-PCXVideoSegment `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300-VideoSegments.json" |
Where-Object Action -eq 'Remove' |
Export-PCXPremiereMarkers -Force -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300-RemoveMarkers.jsx"

Import-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300-Analysis.json" |
Get-PCXVideoSegments |
Where-Object Action -eq 'Remove' |
Export-PCXPremiereEditPoints -Force -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300-RemoveEditPoints.jsx"

#
old comamnd to recheck
Analyze-PCXVideo `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300.mp4" |
Get-PCXVideoSegments |
Where-Object Action -eq 'Remove' |
Export-PCXPremiereMarkers -Force

 