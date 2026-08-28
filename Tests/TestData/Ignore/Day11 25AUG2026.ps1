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

<<<<<<< HEAD
 ########################################

 #Synced
=======
########################################

#Synced
>>>>>>> feature/synchronized-editing-workflow
 
Edit-PCXRecordingSession `
    -ReferencePath "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST\bandicam 2026-04-12 03-08-19-300.mp4" `
    -SourcePaths @(
    "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST\VID_20260412_030812.mp4",
    "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST\bandicam 2026-04-12 03-08-19-300.mp4.webcam.mp4"
)
<<<<<<< HEAD
=======


# New command
Invoke-PCXSynchronizedEditing `
    -ReferencePath "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST\bandicam 2026-04-12 03-08-19-300.mp4" `
    -SourcePaths @(
    "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST\VID_20260412_030812.mp4",
    "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST\bandicam 2026-04-12 03-08-19-300.mp4.webcam.mp4"
)



git log --oneline --decorate agents/pasted-text-processing --not main

git branch -d agents/pasted-text-processing

git checkout main
git pull
git log --oneline --decorate -5


git add .

git commit -m "Add standalone checkpoint-aware batch processor"

git status


git push

git branch
git checkout main

git pull


git merge feature/editing-architecture

git push
\


git checkout -b feature/synchronized-editing-workflow

git log --oneline --decorate --graph -10

git log agents/pasted-text-processing --not main


#### With only remve filtered

Import-PCXVideoSegment `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST\bandicam 2026-04-12 03-08-19-300-VideoSegments.json" |
Where-Object Action -eq 'Remove' |
Export-PCXPremiereMarkers -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST\bandicam 2026-04-12 03-08-19-300-RemoveMarkers.jsx"


Remove-Module PCXLab.VideoTools -ErrorAction SilentlyContinue
Import-Module "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools" -Force


Invoke-PCXSynchronizedEditing `
    -ReferencePath "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST\bandicam 2026-04-12 03-08-19-300.mp4" `
    -SourcePaths @(
    "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST\VID_20260412_030812.mp4",
    "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST\bandicam 2026-04-12 03-08-19-300.mp4.webcam.mp4"
)


Edit-PCXRecordingSession `
    -ReferencePath "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST\bandicam 2026-04-12 03-08-19-300.mp4" `
    -SourcePaths @(
    "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST\VID_20260412_030812.mp4",
    "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST\bandicam 2026-04-12 03-08-19-300.mp4.webcam.mp4"
)


(Get-Command Invoke-PCXSynchronizedEditing).Source

(Get-Command Edit-PCXRecordingSession).Source


git status

git diff --stat


Get-Content "src\Modules\PCXLab.VideoTools\1.1.0\Public\Synchronization\Invoke-PCXSynchronizedEditing.ps1"
Get-Content "src\Modules\PCXLab.VideoTools\1.1.0\Public\Synchronization\Edit-PCXRecordingSession.ps1"
Get-Content "src\Modules\PCXLab.VideoTools\1.1.0\Private\Synchronization\Invoke-PCXSynchronizedEditingInternal.ps1"


"src\Modules\PCXLab.VideoTools\1.1.0\Public\Synchronization\Invoke-PCXSynchronizedEditing.ps1"
"src\Modules\PCXLab.VideoTools\1.1.0\Public\Synchronization\Edit-PCXRecordingSession.ps1"
"src\Modules\PCXLab.VideoTools\1.1.0\Private\Synchronization\Invoke-PCXSynchronizedEditingInternal.ps1"


Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue

Import-Module "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools" -Force


Invoke-PCXSynchronizedEditing "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST\bandicam 2026-04-12 03-08-19-300.mp4"

Invoke-PCXSynchronizedEditing `
    -ReferencePath "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST\bandicam 2026-04-12 03-08-19-300.mp4" `
    -SourcePaths @(
    "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST\VID_20260412_030812.mp4",
    "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST\bandicam 2026-04-12 03-08-19-300.mp4.webcam.mp4"
)



############################################################

# RemoveMarkers.jsx
$VideoSegmentsJson = "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST\bandicam 2026-04-12 03-08-19-300-VideoSegments.json"
$RemoveMarkersExportPath = $VideoSegmentsJson + "-RemoveMarkers.jsx"
Import-PCXVideoSegment `
    -Path $VideoSegmentsJson |
Where-Object Action -eq 'Remove' |
Export-PCXPremiereMarkers -Path $RemoveMarkersExportPath


# RemoveEditPoints.jsx
$Analysisjson = "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260412_030812_001 - SYNCTEST\VID_20260412_030812-Edited-Analysis.json"
$RemoveEditPointsExportPath = $Analysisjson + "-RemoveEditPoints.jsx"
Import-PCXVideoAnalysis `
    -Path $Analysisjson |
Get-PCXVideoSegments |
Where-Object Action -eq 'Remove' |
Export-PCXPremiereEditPoints -Path $RemoveEditPointsExportPath   

############################################################



>>>>>>> feature/synchronized-editing-workflow


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


