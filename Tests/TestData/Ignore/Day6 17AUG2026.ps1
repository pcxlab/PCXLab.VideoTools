
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

# C:\Recording seg TestONLOY\RG_20260127_025337_001 C ShortPauseTRUE this file i think erlier processed bedacuse frm 24min to 18min
Edit-PCXRecordingSession `
    -ReferencePath "C:\Recording seg TestONLOY\RG_20260127_025337_001 C ShortPauseTRUE\bandicam.mp4" `
    -SourcePaths @(
    "C:\Recording seg TestONLOY\RG_20260127_025337_001 C ShortPauseTRUE\VID_20260127_025337.mp4",
    "C:\Recording seg TestONLOY\RG_20260127_025337_001 C ShortPauseTRUE\bandicam.webcam.mp4"
) `
    -OutputDirectory "C:\Recording seg TestONLOY"

#rerunning once again same command
# chanigng json true to false


#C:\Recording seg TestONLOY\RG_20260127_025337_001 A OriginalFiles


Edit-PCXRecordingSession `
    -ReferencePath "C:\Recording seg TestONLOY\RG_20260127_025337_001 A OriginalFiles\bandicam.mp4" `
    -SourcePaths @(
    "C:\Recording seg TestONLOY\RG_20260127_025337_001 A OriginalFiles\VID_20260127_025337.mp4",
    "C:\Recording seg TestONLOY\RG_20260127_025337_001 A OriginalFiles\bandicam.webcam.mp4"
) `
    -OutputDirectory "C:\Recording seg TestONLOY"



git add .

git status  

git commit -m "Refactor synchronization architecture to use behavior-driven MediaSource model

- Extend PCXLab.MediaSource with SynchronizationMethod, AnalysisMode, and RenderingMode
- Add capability-check and resolver functions for synchronization, analysis, and rendering
- Refactor Sync-PCXMedia and Sync-PCXEditPoint to use resolvers while preserving existing algorithms
- Redesign Edit-PCXRecordingSession with legacy Path and new MediaSource parameter sets
- Isolate Bandicam compatibility shim in Build-PCXMediaSourcesFromPaths
- Preserve backward compatibility for existing RecordingSession.json caches
- Update recording session import/export for behavior property round-tripping
- Add unit and integration tests for resolvers, capability checks, and recording session round-trip"

git push

git tag -a synchronization-architecture-refactor -m "Behavior-driven synchronization architecture"
git push origin synchronization-architecture-refactor

