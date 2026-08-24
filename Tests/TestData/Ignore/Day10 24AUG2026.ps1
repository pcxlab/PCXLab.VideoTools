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
feat(editing): complete artifact-based Premiere marker workflow
"@

git commit -m $message
git push

Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue
Import-Module .\src\Modules\PCXLab.VideoTools -Force

Analyze-PCXVideo `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253.mp4" |
Get-PCXVideoSegments |
Edit-PCXVideoSegments -Force

Get-Command Import-PCXVideoAnalysis


###################

Analyze-PCXVideo `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300.mp4" |
Get-PCXVideoSegments |
Edit-PCXVideoSegments -Force


##################

Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue
Import-Module .\src\Modules\PCXLab.VideoTools -Force

Analyze-PCXVideo `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300.mp4" |
Export-PCXVideoAnalysis -Force


Import-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300-VideoAnalysis.json" |
Export-PCXPremiereMarkers `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\AnalysisMarkers-FromJson.jsx" `
    -Force


#################@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


#Step 1 – Analyze → VideoAnalysis.json
Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue
Import-Module .\src\Modules\PCXLab.VideoTools -Force

Analyze-PCXVideo `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300.mp4" |
Export-PCXVideoAnalysis -Force

#Step 2 – Import JSON → Export Analysis Markers
Import-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300-Analysis.json" |
Export-PCXPremiereMarkers `
    -Force

#Step 3 – Import JSON → Generate VideoSegments
Import-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300-Analysis.json" |
Get-PCXVideoSegments |
Export-PCXVideoSegment -Force

#Step 4 – Import VideoSegments → Export Editing Markers
Import-PCXVideoSegment `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300-Analysis.json" |
Export-PCXPremiereMarkers `
    -Force

#⭐ Step 5 – Import VideoSegments → Render Final Video
Import-PCXVideoSegment `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300-Analysis.json" |
Edit-PCXVideoSegments -Force


#Export edit markers
Import-PCXVideoSegment `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300-VideoSegments.json" |
Export-PCXPremiereMarkers -Force


#Render the edited video
Import-PCXVideoSegment `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300-VideoSegments.json" |
Edit-PCXVideoSegments

#If it STILL fails


Import-PCXVideoSegment `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300-Analysis.json" |
Get-PCXVideoSegments |
Where-Object Action -eq 'Remove' |
Export-PCXPremiereMarkers -Force


Import-PCXVideoSegment `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300-VideoSegments.json" |
Where-Object Action -eq 'Remove' |
Export-PCXPremiereMarkers -Force



Analyze-PCXVideo `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300.mp4" |
Get-PCXVideoSegments |
Where-Object Action -eq 'Remove' |
Export-PCXPremiereMarkers -Force


Import-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300-Analysis.json" |
Get-PCXVideoSegments |
Where-Object Action -eq 'Remove' |
Export-PCXPremiereEditPoints -Force


Import-PCXVideoSegment `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300-VideoSegments.json" |
Where-Object Action -eq 'Remove' |
Export-PCXPremiereEditPoints -Force


Analyze-PCXVideo `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300.mp4" |
Get-PCXVideoSegments |
Edit-PCXVideoSegments -Force


Analyze-PCXVideo `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300.mp4" |
Get-PCXVideoSegments |
Edit-PCXVideoSegments -Force

Analyze-PCXVideo `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300.mp4" |
Get-PCXVideoSegments |
Edit-PCXVideoSegments


Analyze-PCXVideo `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001\bandicam 2026-04-12 03-08-19-300.mp4" |
Get-PCXVideoSegments |
Edit-PCXVideoSegments