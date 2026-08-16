
Clear-Host

Remove-Module PCXLab.VideoTools -Force
Import-Module .\src\Modules\PCXLab.VideoTools -Force
Get-Module -Name PCXLab.VideoTools
Get-Command -Module PCXLab.VideoTools

Test-PCXVideoTools

#@#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

#==========================================================
# Reload Module
#==========================================================

Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue
Import-Module ".\src\Modules\PCXLab.VideoTools" -Force

#==========================================================
# Test File
#==========================================================

$Path = "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4"

#==========================================================
# Test 1 - Media Information
#==========================================================

Write-Host ""
Write-Host "================ TEST 1 - MEDIA =================" -ForegroundColor Cyan

$Media = Get-PCXMediaInformation -Path $Path

$Media | Format-List *

#==========================================================
# Test 2 - Audio Information
#==========================================================

Write-Host ""
Write-Host "================ TEST 2 - AUDIO =================" -ForegroundColor Cyan

$Audio = Get-PCXAudioInformation -Path $Path

$Audio | Format-List *

#==========================================================
# Test 3 - Silence Detection
#==========================================================

Write-Host ""
Write-Host "================ TEST 3 - SILENCE =================" -ForegroundColor Cyan

$Silence = @(
    Find-PCXSilence `
        -Path $Path `
        -NoiseFloor -35 `
        -MinimumDuration 1
)

"Silence Count = $($Silence.Count)"

$Silence | Format-Table

#==========================================================
# Test 4 - Full Analysis
#==========================================================

Write-Host ""
Write-Host "================ TEST 4 - ANALYSIS =================" -ForegroundColor Cyan

$Analysis = Get-PCXVideoAnalysis -Path $Path

$Analysis | Format-List *

#==========================================================
# Test 5 - Analysis Summary
#==========================================================

Write-Host ""
Write-Host "================ TEST 5 - ANALYSIS CONTENT =================" -ForegroundColor Cyan

"Silence Count : $($Analysis.Analysis.Silence.Count)"
"Segment Count : $($Analysis.Analysis.Segments.Count)"

$Analysis.Analysis.Segments |
Format-Table

#==========================================================
# Test 6 - First Segment
#==========================================================

Write-Host ""
Write-Host "================ TEST 6 - FIRST SEGMENT =================" -ForegroundColor Cyan

$Analysis.Analysis.Segments |
Select-Object -First 1 |
Format-List *

#==========================================================
# Test 7 - Render From Analysis Segments
#==========================================================

Write-Host ""
Write-Host "================ TEST 7 - RENDER =================" -ForegroundColor Cyan

$Output = "C:\Temp\Test-Webcam.mp4"

Remove-Item $Output -ErrorAction Ignore

$Analysis.Analysis.Segments |
Edit-PCXVideoSegments `
    -OutputPath $Output

Write-Host ""
Write-Host "Output Exists:" (Test-Path $Output)

if (Test-Path $Output) {
    Get-Item $Output | Format-List FullName, Length, LastWriteTime
}

#==========================================================
# Test Complete
#==========================================================

Write-Host ""
Write-Host "================ TEST COMPLETE =================" -ForegroundColor Green


Remove-Module PCXLab.VideoTools -Force
Import-Module .\src\Modules\PCXLab.VideoTools -Force

$MediaSources |
Select-Object Id, Role, OffsetHint, Path |
Format-Table -AutoSize


Edit-PCXRecordingSession `
    -ReferencePath "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4" `
    -SourcePaths @(
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4",
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4"
) `
    -OutputDirectory "C:\Recording seg TestONLOY"


$Analysis = Get-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"

$EditPoints = $Analysis |
Find-PCXSilence |
Get-PCXEditPoint

$EditPoints.Count

$EditPoints | Format-Table

###############################

$Analysis = Get-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"

$Analysis | Format-List *


$Silence = $Analysis |
Find-PCXSilence

$Silence.Count

$Silence | Select StartSeconds, EndSeconds, Classification

$EditPoints = $Silence |
Get-PCXEditPoint

$EditPoints.Count

$EditPoints |
Format-Table SourcePath, Action, TimeSeconds

$MediaSources = @(
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4" |
    New-PCXMediaSource

    "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4" |
    New-PCXMediaSource

    "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4" |
    New-PCXMediaSource -OffsetHint 0
)

$Session = $MediaSources |
Get-PCXRecordingSession

$Translated = $EditPoints |
Sync-PCXEditPoint `
    -RecordingSession $Session

$Translated.Count

$All = @($EditPoints) + @($Translated)

$All.Count

$All |
Group-Object SourcePath |
Format-Table Name, Count

cls

$Analysis = Get-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"

$Silence = $Analysis | Find-PCXSilence

$Silence |
Select-Object -First 5 Classification


Get-PCXEditPointRule -Classification ShortPause | Format-List *


Get-Command Get-PCXEditPointRule -All

Get-ChildItem . -Recurse -Filter *.ps1 |
Select-String "function Get-PCXEditPointRule"


Get-PCXSetting -Name "Analysis.EditPoints"

Get-PCXSetting -Name "Analysis.EditPoints" -DefaultValue @{} | Format-List *

Get-PCXSetting -Name "Analysis.EditPoints"

Get-PCXSetting -Name "Analysis"


$Analysis = Get-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"

$Analysis |
Find-PCXSilence |
Get-PCXEditPoint |
Measure-Object


############################

#==========================================================
# Reload Module
#==========================================================

Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue
Import-Module ".\src\Modules\PCXLab.VideoTools" -Force

#==========================================================
# Test File
#==========================================================

$Path = "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"

#==========================================================
# TEST 1 - Analysis
#==========================================================

Write-Host ""
Write-Host "================ ANALYSIS =================" -ForegroundColor Cyan

$Analysis = Get-PCXVideoAnalysis -Path $Path

"Silence Count : $($Analysis.Analysis.Silence.Count)"
"Segment Count : $($Analysis.Analysis.Segments.Count)"

#==========================================================
# TEST 2 - Silence
#==========================================================

Write-Host ""
Write-Host "================ SILENCE =================" -ForegroundColor Cyan

$Silence = $Analysis |
Find-PCXSilence

"Silence Count : $($Silence.Count)"

$Silence |
Select-Object -First 5 StartSeconds, EndSeconds, Classification |
Format-Table

#==========================================================
# TEST 3 - Edit Points
#==========================================================

Write-Host ""
Write-Host "================ EDIT POINTS =================" -ForegroundColor Cyan

$EditPoints = $Silence |
Get-PCXEditPoint

"Edit Point Count : $($EditPoints.Count)"

if ($EditPoints.Count -gt 0) {

    $EditPoints |
    Select-Object -First 10 |
    Format-Table

}

#==========================================================
# TEST 4 - Segments
#==========================================================

Write-Host ""
Write-Host "================ SEGMENTS =================" -ForegroundColor Cyan

$Segments = $EditPoints |
Get-PCXVideoSegments

"Segment Count : $($Segments.Count)"

if ($Segments.Count -gt 0) {

    $Segments |
    Select-Object -First 10 |
    Format-Table

}

Write-Host ""
Write-Host "================ COMPLETE =================" -ForegroundColor Green

$Analysis = Get-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"

$Analysis |
Find-PCXSilence |
Get-PCXEditPoint


Remove-Module PCXLab.VideoTools -Force
Import-Module .\src\Modules\PCXLab.VideoTools -Force


$Analysis = Get-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"

$Analysis |
Find-PCXSilence |
Get-PCXEditPoint

###########################

Remove-Module PCXLab.VideoTools -Force -ErrorAction Ignore

Import-Module .\src\Modules\PCXLab.VideoTools -Force

$Analysis = Get-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"

$EditPoints = $Analysis |
Find-PCXSilence |
Get-PCXEditPoint -Verbose

$EditPoints.Count

$EditPoints |
Format-Table


Edit-PCXRecordingSession `
    -ReferencePath "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4" `
    -SourcePaths @(
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4",
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4"
) `
    -OutputDirectory "C:\Recording seg TestONLOY"


$Analysis = Get-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"

$Segments = $Analysis |
Find-PCXSilence |
Get-PCXEditPoint |
Get-PCXVideoSegments

$Segments.Count

$Segments |
Select-Object -First 10 |
Format-Table


$EditPoints = $Analysis |
Find-PCXSilence |
Get-PCXEditPoint

$EditPoints |
Get-Member



git diff -- Tests/Editing/Get-PCXVideoDuration.Tests.ps1
git diff -- Tests/Public/Find-PCXSilence.Tests.ps1

git diff -- src/Modules/PCXLab.VideoTools/1.1.0/Private/Editing/ConvertTo-PCXConcatFilter.ps1
git diff -- src/Modules/PCXLab.VideoTools/1.1.0/Private/Editing/Invoke-PCXFFmpegEdit.ps1
git diff -- src/Modules/PCXLab.VideoTools/1.1.0/Private/Models/New-PCXEditJobObject.ps1
git diff -- src/Modules/PCXLab.VideoTools/1.1.0/Private/Models/New-PCXVideoAnalysisObject.ps1
git diff -- src/Modules/PCXLab.VideoTools/1.1.0/Private/Settings/Get-PCXEditPointRule.ps1
git diff -- src/Modules/PCXLab.VideoTools/1.1.0/Public/Analysis/Analyze-PCXVideo.ps1
git diff -- src/Modules/PCXLab.VideoTools/1.1.0/Public/Analysis/Find-PCXSilence.ps1
git diff -- src/Modules/PCXLab.VideoTools/1.1.0/Public/Analysis/Get-PCXEditPoint.ps1
git diff -- src/Modules/PCXLab.VideoTools/1.1.0/Public/Editing/Edit-PCXVideoSegments.ps1
git diff -- src/Modules/PCXLab.VideoTools/1.1.0/Public/Synchronization/Edit-PCXRecordingSession.ps1
git diff -- src/Modules/PCXLab.VideoTools/1.1.0/Public/Synchronization/Get-PCXRecordingSession.ps1
git diff -- src/Modules/PCXLab.VideoTools/1.1.0/Public/Synchronization/New-PCXMediaSource.ps1
git diff -- src/Modules/PCXLab.VideoTools/1.1.0/Public/Utilities/Test-PCXVideoTools.ps1



git diff -- src/Modules/PCXLab.VideoTools/1.1.0/Public/Analysis/Get-PCXVideoSegments.ps1
git diff -- src/Modules/PCXLab.VideoTools/1.1.0/Public/Analysis/Get-PCXEditPoint.ps1
git diff -- src/Modules/PCXLab.VideoTools/1.1.0/Private/Models/New-PCXEditPointObject.ps1
git diff -- src/Modules/PCXLab.VideoTools/1.1.0/Public/Synchronization/Edit-PCXRecordingSession.ps1
git diff -- src/Modules/PCXLab.VideoTools/1.1.0/Public/Editing/Edit-PCXVideoSegments.ps1
git diff -- src/Modules/PCXLab.VideoTools/1.1.0/Private/Editing/Invoke-PCXFFmpegEdit.ps1
git diff -- src/Modules/PCXLab.VideoTools/1.1.0/Private/Editing/ConvertTo-PCXConcatFilter.ps1