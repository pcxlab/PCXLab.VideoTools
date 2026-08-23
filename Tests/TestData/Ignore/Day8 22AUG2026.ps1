
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
refactor(rendering): encapsulate FFmpeg filter graph assembly

- Add ConvertTo-PCXFFmpegFilterGraph
- Move FFmpeg graph assembly out of Edit-PCXVideoSegments
- Keep rendering builder deterministic via injected AudioSettings
- Add unit tests for filter graph compilation
"@

git commit -m $message
git push



Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue
Import-Module .\src\Modules\PCXLab.VideoTools -Force

Find-PCXSilence `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253.mp4" |
Get-PCXVideoSegments |
Edit-PCXVideoSegments -Force




Edit-PCXRecordingSession `
    -ReferencePath "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253.mp4" `
    -SourcePaths @(
    "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\VID_20260127_025337.mp4",
    "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253.mp4.webcam.mp4"
)

#1. VideoAnalysis.json
Analyze-PCXVideo `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253.mp4" |
Export-PCXVideoAnalysis -Force

#2. VideoSegments.json
Find-PCXSilence `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253.mp4" |
Get-PCXVideoSegments |
Export-PCXVideoSegment -Force

#3. Premiere Edit Points (.jsx)
Find-PCXSilence `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253.mp4" |
Get-PCXVideoSegments |
Export-PCXPremiereEditPoints -Force

#4. Premiere Markers (.jsx)
Find-PCXSilence `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253.mp4" |
Get-PCXVideoSegments |
Export-PCXPremiereMarkers -Force

###################################


# 1. Raw silence visualization
Find-PCXSilence `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253.mp4" |
Export-PCXPremiereMarkers `
    -Path ".\SilenceMarkers.jsx"

# You should now get silence markers, not Keep/Remove segment markers.
# 2. Full analysis visualization
Analyze-PCXVideo `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253.mp4" |
Export-PCXPremiereMarkers `
    -Path ".\AnalysisMarkers.jsx"

# This verifies that PCXLab.VideoAnalysis is unpacked correctly by the dispatcher.

#3. Existing workflow (regression test)

Find-PCXSilence `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253.mp4" |
Get-PCXVideoSegments |
Export-PCXPremiereMarkers `
    -Path ".\SegmentMarkers.jsx"

#This should produce the same Keep/Remove markers you've already been using.


Analyze-PCXVideo `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253_5min.mp4" |
Get-PCXVideoSegments |
Export-PCXVideoSegment -Force

Analyze-PCXVideo `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253_5min.mp4" |
Get-PCXVideoSegments |
Edit-PCXVideoSegments -Force

#
Analyze-PCXVideo `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253_5min.mp4" |
Export-PCXPremiereMarkers -Force


Analyze-PCXVideo `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253_5min.mp4" |
Get-PCXVideoSegments |
Export-PCXPremiereEditPoints -Force


Add-PCXRemoveSegment
Optimize-PCXVideoSegments