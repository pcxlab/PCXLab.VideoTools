
Clear-Host

Remove-Module PCXLab.VideoTools -Force
Import-Module .\src\Modules\PCXLab.VideoTools
Get-Module -Name PCXLab.VideoTools
Get-Command -Module PCXLab.VideoTools

Test-PCXVideoTools


Clear-Host

# ============================================================
# PCXLab.VideoTools 1.1.0 - Functional Test Pass
# Test video: C:\Videos\Test.mp4
# ============================================================

# 1. Media information
Get-PCXMediaInformation -Path "C:\Videos\Test.mp4"

Get-PCXMediaInformation -Path "F:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam 2026-01-27 02-53-49-253.mp4"
Get-PCXMediaInformation -Path "F:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam 2026-01-27 02-53-49-253.mp4.webcam.mp4"
Get-PCXMediaInformation -Path "F:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4"

"F:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam 2026-01-27 02-53-49-253.mp4" (bandicam clarity audio video + audio)
"F:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam 2026-01-27 02-53-49-253.mp4.webcam.mp4" (bandicam but no audio its only logtech cam footage)
"F:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4" (nokia video + audio)

Get-PCXPrimaryAudioStream -Path "C:\Videos\Test.mp4"

Get-PCXPrimaryAudioStream -Path "C:\Videos\Test.mp4"

# 2. Video information
Get-PCXVideoInformation -Path "C:\Videos\Test.mp4"

# 3. Audio information
Get-PCXAudioInformation -Path "C:\Videos\Test.mp4"

# 4. Media streams
Get-PCXMediaStreams -Path "C:\Videos\Test.mp4"

# 5. Chapter information
Get-PCXChapterInformation -Path "C:\Videos\Test.mp4"

# 6. Subtitle information
Get-PCXSubtitleInformation -Path "C:\Videos\Test.mp4"

# 7. Analyze video
Analyze-PCXVideo -Path "C:\Videos\Test.mp4"

# 8. Find silence
Find-PCXSilence -Path "C:\Videos\Test.mp4"

# 9. Get silence
Get-PCXSilence -Path "C:\Videos\Test.mp4"

# 10. Measure silence
Measure-PCXSilence -Path "C:\Videos\Test.mp4"

# 11. Get video segments
Get-PCXVideoSegments -Path "C:\Videos\Test.mp4"

# 12. Remove silence
Remove-PCXSilence -Path "C:\Videos\Test.mp4"

# 13. Verify edited output
Get-Item "C:\Videos\Test-Edited.mp4"

# 14. Verify temporary filter-graph cleanup
Get-ChildItem "$env:TEMP\PCXLab\VideoTools\FilterGraphs" -ErrorAction SilentlyContinue

Get-ChildItem "$env:TEMP\PCXLab\VideoTools\FilterGraphs" -ErrorAction SilentlyContinue

# 15. Check Git status
git status --short

# 1. Verify the generated video is valid
Get-PCXMediaInformation -Path "C:\Videos\Test-Edited.mp4"

# 2. Verify video information
Get-PCXVideoInformation -Path "C:\Videos\Test-Edited.mp4"

# 3. Verify audio information
Get-PCXAudioInformation -Path "C:\Videos\Test-Edited.mp4"

# 4. Verify streams
Get-PCXMediaStreams -Path "C:\Videos\Test-Edited.mp4"

# 5. Verify output file size
Get-Item "C:\Videos\Test-Edited.mp4" | Select-Object FullName, Length, LastWriteTime

# 6. Verify the filter graph was cleaned up
Get-ChildItem "$env:TEMP\PCXLab\VideoTools\FilterGraphs" -ErrorAction SilentlyContinue
Get-ChildItem "$env:TEMP\PCXLab\VideoTools\FilterGraphs" -ErrorAction SilentlyContinue

# 7. Check whether any filter graph files exist anywhere under our TEMP area
Get-ChildItem "$env:TEMP\PCXLab\VideoTools" -Recurse -File -ErrorAction SilentlyContinue

# 8. Verify the source video is still untouched
Get-PCXMediaInformation -Path "C:\Videos\Test.mp4"

$Bandicam = "F:\Recordings\20260127\RG_20260127_110511_002\bandicam 2026-01-27 11-05-31-027.mp4"
$Nokia = "F:\Recordings\20260127\RG_20260127_110511_002\VID_20260127_110535.mp4"
C:\Projects\PCXLab.VideoTools\Tools\FFmpeg\bin\ffprobe.exe -v error -show_entries format=duration -show_entries stream=index, codec_type, codec_name, sample_rate, channels, duration -of json $Bandicam
C:\Projects\PCXLab.VideoTools\Tools\FFmpeg\bin\ffprobe.exe -v error -show_entries format=duration -show_entries stream=index, codec_type, codec_name, sample_rate, channels, duration -of json $Nokia

$ref = New-PCXMediaSource -Path $Nokia -Id 'Reference'
$src = New-PCXMediaSource -Path $Bandicam -Id 'Source'

$ref, $src | Format-Table Id, Path, AudioStreamIndex


$result = & $module {
    param($ReferenceSource, $TargetSource)

    Measure-PCXSourceOffsetAudioCorrelation `
        -ReferenceSource $ReferenceSource `
        -TargetSource $TargetSource `
        -MinimumConfidence 0 `
        -MaxOffsetSeconds 300 `
        -TempPath $env:TEMP

} $ref $src

$result | Format-List *

$result = & $module {
    param($ReferenceSource, $TargetSource)

    Measure-PCXSourceOffsetAudioCorrelation `
        -ReferenceSource $ReferenceSource `
        -TargetSource $TargetSource `
        -MinimumConfidence 0 `
        -MaxOffsetSeconds 15 `
        -TempPath $env:TEMP

} $ref $src

$result | Format-List *

#############################################################


$Bandicam = "F:\Recordings\20260127\RecordingGroup_20260127_111934_003\bandicam 2026-01-27 11-20-02-160.mp4"
$Nokia = "F:\Recordings\20260127\RecordingGroup_20260127_111934_003\VID_20260127_111934.mp4"

C:\Projects\PCXLab.VideoTools\Tools\FFmpeg\bin\ffprobe.exe -v error -show_entries format=duration -show_entries stream=index, codec_type, codec_name, sample_rate, channels, duration -of json $Bandicam

C:\Projects\PCXLab.VideoTools\Tools\FFmpeg\bin\ffprobe.exe -v error -show_entries format=duration -show_entries stream=index, codec_type, codec_name, sample_rate, channels, duration -of json $Nokia

$ref = New-PCXMediaSource -Path $Nokia -Id 'Reference'
$src = New-PCXMediaSource -Path $Bandicam -Id 'Source'

$ref, $src | Format-Table Id, Path, AudioStreamIndex

#Test 1 — Nokia reference → Bandicam source, 300 seconds
$result300 = & $module {
    param($ReferenceSource, $TargetSource)

    Measure-PCXSourceOffsetAudioCorrelation `
        -ReferenceSource $ReferenceSource `
        -TargetSource $TargetSource `
        -MinimumConfidence 0 `
        -MaxOffsetSeconds 300 `
        -TempPath $env:TEMP

} $ref $src

$result300 | Format-List *

#Test 2 — Same direction, but 15 seconds
$result15 = & $module {
    param($ReferenceSource, $TargetSource)

    Measure-PCXSourceOffsetAudioCorrelation `
        -ReferenceSource $ReferenceSource `
        -TargetSource $TargetSource `
        -MinimumConfidence 0 `
        -MaxOffsetSeconds 15 `
        -TempPath $env:TEMP

} $ref $src

$result15 | Format-List *

#Test 3 — Bandicam reference → Nokia source, 15 seconds
$refBandicam = New-PCXMediaSource -Path $Bandicam -Id 'ReferenceBandicam'
$srcNokia = New-PCXMediaSource -Path $Nokia -Id 'SourceNokia'

$resultReverse = & $module {
    param($ReferenceSource, $TargetSource)

    Measure-PCXSourceOffsetAudioCorrelation `
        -ReferenceSource $ReferenceSource `
        -TargetSource $TargetSource `
        -MinimumConfidence 0 `
        -MaxOffsetSeconds 15 `
        -TempPath $env:TEMP

} $refBandicam $srcNokia

$resultReverse | Format-List *

######################

$message = "feat(cache): complete persistent analysis cache architecture

- Complete Analysis.json import/export pipeline
- Restore object types after deserialization
- Support downstream analysis without rerunning FFmpeg
- Verify cache compatibility for silence reports and edit points"

git add .

git status
git commit -m "$message"

git push -u origin main


$message = @"
feat(sync-cache): add persistent Recording Session cache

- Add Export-PCXRecordingSession
- Add Import-PCXRecordingSession
- Restore synchronization object types after JSON import
- Persist synchronization results without correlation evidence
- Extend Get-PCXDefaultOutputPath with fixed filename support
- Add RecordingSession.json as the reusable synchronization cache
- Preserve expensive audio-correlation results for future reuse
"@


$message = @"
feat(sync-cache): add recording session cache reuse

- Add Get-PCXRecordingSession public orchestrator
- Add Get-PCXRecordingSessionPath helper
- Add Test-PCXRecordingSessionCache helper
- Extend Get-PCXDefaultOutputPath with fixed filename support
- Reuse RecordingSession.json when available
- Preserve Sync-PCXMedia as the synchronization compute engine
- Add cache reuse verification
"@

git add .
git commit -m "$message"
git push

$message = @"
feat(sync-edit): add synchronized edit point translation

- Add Sync-PCXEditPoint
- Add Convert-PCXEditPointToSource
- Translate reference edit points to synchronized sources
- Reuse RecordingSession.json offsets
- Preserve existing editing pipeline
"@

git add .
git commit -m "$message"
git push

$message = @"
refactor(edit): make video segment generation type-agnostic

- Allow Get-PCXVideoSegments to accept PCXLab.EditPoint
- Preserve existing Silence behavior
- Keep segment generation algorithm unchanged
- Reuse the same segment builder for synchronized edits 
"@

$message = @"
refactor(rendering): extract reusable video segment renderer

- Add Edit-PCXVideoSegments
- Refactor Remove-PCXSilence into a thin orchestrator
- Add single-source validation for video segments
- Reuse the shared rendering pipeline
- Preserve existing FFmpeg rendering behavior
"@

git add .
git commit -m "$message"
git push

$message = @"
feat(cache): add persistent video analysis cache

- Add Get-PCXVideoAnalysis
- Add Get-PCXAnalysisPath
- Add Test-PCXVideoAnalysisCache
- Reuse Analysis.json when available
- Preserve Analyze-PCXVideo behavior
"@

git add .
git commit -m "$message"
git push


$message = @"
Fix single SourcePath validation robustness

- Normalize unique SourcePath collections in Get-PCXVideoSegments
- Normalize unique SourcePath collections in Edit-PCXVideoSegments
- Prevent PropertyNotFoundException when only one SourcePath exists
- Preserve existing validation and behavior
"@

git add .
git commit -m "Add OffsetHint fallback for video-only sources in Sync-PCXMedia"
git push


Edit-PCXRecordingSession `
    -ReferencePath "F:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam 2026-01-27 02-53-49-253.mp4" `
    -SourcePaths @(
    "F:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4"
) `
    -Verbose



    
Edit-PCXRecordingSession `
    -ReferencePath "F:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam 2026-01-27 02-53-49-253.mp4" `
    -SourcePaths @(
    "F:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4",
    "F:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam 2026-01-27 02-53-49-253.mp4.webcam.mp4"
) `
    -Verbose


# Existing behaviour
Get-PCXMediaInformation -Path "C:\Videos\Test.mp4"

# Video-only media
Get-PCXMediaInformation -Path "F:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam 2026-01-27 02-53-49-253.mp4.webcam.mp4"

# MediaSource creation
New-PCXMediaSource -Path "F:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam 2026-01-27 02-53-49-253.mp4.webcam.mp4"

# Original synchronized workflow
Edit-PCXRecordingSession ...


Get-PCXMediaInformation -Path "F:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam 2026-01-27 02-53-49-253.mp4.webcam.mp4"

New-PCXMediaSource -Path "F:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam 2026-01-27 02-53-49-253.mp4.webcam.mp4"


Analyze-PCXVideo -Path "C:\Videos\Test.mp4"

Remove-PCXSilence -Path "C:\Videos\Test.mp4"

Get-PCXVideoAnalysis -Path "C:\Videos\Test.mp4"

Edit-PCXRecordingSession ...



$seg1 = [PSCustomObject]@{
    PSTypeName = 'PCXLab.VideoSegment'
    SourcePath = "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"
    Start      = [TimeSpan]::Zero
    End        = [TimeSpan]::FromSeconds(5)
}

$seg2 = [PSCustomObject]@{
    PSTypeName = 'PCXLab.VideoSegment'
    SourcePath = "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4"
    Start      = [TimeSpan]::FromSeconds(5)
    End        = [TimeSpan]::FromSeconds(10)
}

@($seg1, $seg2) | Edit-PCXVideoSegments




$analysis = Analyze-PCXVideo -Path "C:\Videos\Test.mp4"

$analysis.Media.Duration

$cached = Get-PCXVideoAnalysis -Path "C:\Videos\Test.mp4"

$cached.Media.Duration


#################################


$Reference = New-PCXMediaSource `
    -Path "F:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam 2026-01-27 02-53-49-253.mp4"

$Nokia = New-PCXMediaSource `
    -Path "F:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4"

$Webcam = New-PCXMediaSource `
    -Path "F:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam 2026-01-27 02-53-49-253.mp4.webcam.mp4" `
    -OffsetHint 0


$Reference | Format-List Id, HasAudio, HasVideo, OffsetHint

$Nokia | Format-List Id, HasAudio, HasVideo, OffsetHint

$Webcam | Format-List Id, HasAudio, HasVideo, OffsetHint


$Reference = New-PCXMediaSource -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"

$Nokia = New-PCXMediaSource -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4"

@(
    $Reference
    $Nokia
) | Sync-PCXMedia

###########################################

$Reference = New-PCXMediaSource -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"

$Nokia = New-PCXMediaSource -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4"

$Webcam = New-PCXMediaSource `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4" `
    -OffsetHint 0

@(
    $Reference
    $Nokia
    $Webcam
) | Sync-PCXMedia

$Reference = New-PCXMediaSource -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"

$Webcam = New-PCXMediaSource -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4"

@(
    $Reference
    $Webcam
) | Sync-PCXMedia

$Reference = New-PCXMediaSource `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4" `
    -OffsetHint 0

$Nokia = New-PCXMediaSource `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4"

@(
    $Reference
    $Nokia
) | Sync-PCXMedia


Invoke-PCXCorrelation `
    -ReferencePath $ReferencePath `
    -TargetPath $TargetPath `
    -MaxOffsetSeconds $MaxOffsetSeconds


$Reference = New-PCXMediaSource -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"

$Nokia = New-PCXMediaSource -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4"

$Sync = @(
    $Reference
    $Nokia
) | Sync-PCXMedia

$Sync


#######################################

$Reference = New-PCXMediaSource -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"

$Nokia = New-PCXMediaSource -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4"

$Webcam = New-PCXMediaSource `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4" `
    -OffsetHint 0

$Sync = @(
    $Reference
    $Nokia
    $Webcam
) | Sync-PCXMedia

$Sync


$Reference = New-PCXMediaSource -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"

$Webcam = New-PCXMediaSource `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4"

@(
    $Reference
    $Webcam
) | Sync-PCXMedia

$Reference = New-PCXMediaSource `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4" `
    -OffsetHint 0

$Nokia = New-PCXMediaSource `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4"

@(
    $Reference
    $Nokia
) | Sync-PCXMedia



###########################

$Reference = New-PCXMediaSource -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"

$Nokia = New-PCXMediaSource -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4"

$Sync = @(
    $Reference
    $Nokia
) | Sync-PCXMedia

$Sync | Format-List *

$Sync.Timeline.SourceOffsets | Format-List *



############

$Reference = New-PCXMediaSource -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"

$Nokia = New-PCXMediaSource -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4"

$Webcam = New-PCXMediaSource `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4" `
    -OffsetHint 0

$Sync = @(
    $Reference
    $Nokia
    $Webcam
) | Sync-PCXMedia

$Sync | Format-List *

$Sync.Timeline.SourceOffsets | Format-Table *


###

$Reference = New-PCXMediaSource `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"

$Webcam = New-PCXMediaSource `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4"

@(
    $Reference
    $Webcam
) | Sync-PCXMedia


$Reference = New-PCXMediaSource `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4" `
    -OffsetHint 0

$Nokia = New-PCXMediaSource `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4"

@(
    $Reference
    $Nokia
) | Sync-PCXMedia


$Sync.Timeline.SourceOffsets |
Select-Object SourceId, Method, Confidence, OffsetSeconds |
Format-Table -AutoSize


$Sync.Timeline.SourceOffsets | Format-List *


    
Clear-Host

Remove-Module PCXLab.VideoTools -Force
Import-Module .\src\Modules\PCXLab.VideoTools
Get-Module -Name PCXLab.VideoTools
Get-Command -Module PCXLab.VideoTools

Test-PCXVideoTools


################

$Session = @(
    New-PCXMediaSource -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"
    New-PCXMediaSource -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4"
    New-PCXMediaSource -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4" -OffsetHint 0
) | Get-PCXRecordingSession

$Session

#############

$Session.Synchronization.Timeline.SourceOffsets |
Format-List *

    
$Session.Sources |
Select-Object Id, OffsetHint |
Format-Table -AutoSize


$Session |
Export-PCXRecordingSession `
    -Path "C:\Temp\RecordingSession.json"


$Imported =
Import-PCXRecordingSession `
    -Path "C:\Temp\RecordingSession.json"

$Imported.Synchronization.Timeline.SourceOffsets |
Format-List *

$Imported |
Edit-PCXRecordingSession

####################################################################

#----------------------------------------------------------
# Reload Module
#----------------------------------------------------------

Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue

Import-Module ".\src\Modules\PCXLab.VideoTools" -Force

#----------------------------------------------------------
# Verify Module
#----------------------------------------------------------

Test-PCXVideoTools

#----------------------------------------------------------
# Create Media Sources
#----------------------------------------------------------

$Reference = New-PCXMediaSource `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"

$Nokia = New-PCXMediaSource `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4"

$Webcam = New-PCXMediaSource `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4" `
    -OffsetHint 0

#----------------------------------------------------------
# Test Synchronization
#----------------------------------------------------------

$Sync = @(
    $Reference
    $Nokia
    $Webcam
) | Sync-PCXMedia

Write-Host ""
Write-Host "================ Synchronization ================"

$Sync | Format-List *

Write-Host ""
Write-Host "================ Source Offsets ================"

$Sync.Timeline.SourceOffsets |
Format-List *

#----------------------------------------------------------
# Build Recording Session
#----------------------------------------------------------

$Session = @(
    $Reference
    $Nokia
    $Webcam
) | Get-PCXRecordingSession

Write-Host ""
Write-Host "================ Recording Session ================"

$Session | Format-List *

#----------------------------------------------------------
# Export Session
#----------------------------------------------------------

$ExportPath = "C:\Temp\RecordingSession.json"

$Session |
Export-PCXRecordingSession `
    -Path $ExportPath

Write-Host ""
Write-Host "Exported to:"
$ExportPath

#----------------------------------------------------------
# Import Session
#----------------------------------------------------------

$Imported = Import-PCXRecordingSession `
    -Path $ExportPath

Write-Host ""
Write-Host "================ Imported Session ================"

$Imported | Format-List *

#----------------------------------------------------------
# Verify Imported Sources
#----------------------------------------------------------

Write-Host ""
Write-Host "================ Imported Sources ================"

$Imported.Sources |
Select-Object Id, Role, OffsetHint |
Format-Table -AutoSize

#----------------------------------------------------------
# Verify Imported Synchronization
#----------------------------------------------------------

Write-Host ""
Write-Host "================ Imported Synchronization ================"

$Imported.Synchronization | Format-List *

Write-Host ""
Write-Host "================ Imported Source Offsets ================"

$Imported.Synchronization.Timeline.SourceOffsets |
Format-List *

#----------------------------------------------------------
# Inspect Edit-PCXRecordingSession
# (Do NOT render yet)
#----------------------------------------------------------

Write-Host ""
Write-Host "================ Edit Command Metadata ================"

Get-Command Edit-PCXRecordingSession |
Format-List *

Write-Host ""
Write-Host "================ Parameter Sets ================"

(Get-Command Edit-PCXRecordingSession).ParameterSets |
Format-List *

Write-Host ""
Write-Host "================ Imported Object Type ================"

$Imported | Get-Member

Write-Host ""
Write-Host "================ Imported Object ================"

$Imported | Format-List *

Write-Host ""
Write-Host "================ Test Complete ================"



Get-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4" |
Find-PCXSilence |
Get-PCXEditPoint |
Get-PCXVideoSegments |
Edit-PCXVideoSegments

Get-ChildItem "$env:TEMP\PCXLab\VideoTools\FilterGraphs"

Get-Content (
    Get-ChildItem "$env:TEMP\PCXLab\VideoTools\FilterGraphs" |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
).FullName



$Analysis = Get-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4"

$Analysis.Analysis.Segments | Format-Table



$Analysis = Get-PCXVideoAnalysis -Path webcam.mp4

$Analysis.Analysis.Segments.Count


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

Test-Path "C:\Recording seg TestONLOY"

Edit-PCXRecordingSession `
    -ReferencePath "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4" `
    -SourcePaths @(
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4",
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4"
) `
    -OutputDirectory "C:\Recording seg TestONLOY"


Edit-PCXRecordingSession `
    -ReferencePath "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4" `
    -SourcePaths @(
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4",
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4"
) `
    -OutputDirectory "C:\Recording seg TestONLOY"
    

###########################

Edit-PCXRecordingSession  -ReferencePath "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"
-SourcePaths @(
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4"
) `
    -OutputDirectory "C:\Recording seg TestONLOY"




Get-PCXMediaInformation `
    -Path "C:\Recording seg TestONLOY\bandicam.mp4"

Get-PCXMediaInformation `
    -Path "C:\Recording seg TestONLOY\bandicam.webcam.mp4"

Get-PCXMediaInformation `
    -Path "C:\Recording seg TestONLOY\VID_20260127_025337.mp4"


Get-PCXMediaInformation `
    -Path "C:\Recording seg TestONLOY\bandicam.mp4"

Get-PCXMediaInformation `
    -Path "C:\Recording seg TestONLOY\bandicam.mp4"


##############################

    
Edit-PCXRecordingSession `
    -ReferencePath "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4" `
    -SourcePaths @(
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4"
) `
    -OutputDirectory "C:\Recording seg TestONLOY"



Edit-PCXRecordingSession `
    -ReferencePath "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4" `
    -SourcePaths @(
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4",
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4"
) `
    -OutputDirectory "C:\Recording seg TestONLOY"



Get-ChildItem "C:\Recording seg TestONLOY" |
Select Name, Length


Get-PCXMediaInformation `
    -Path "C:\Recording seg TestONLOY\bandicam.mp4"

Get-PCXMediaInformation `
    -Path "C:\Recording seg TestONLOY\bandicam.webcam.mp4"

Get-PCXMediaInformation `
    -Path "C:\Recording seg TestONLOY\VID_20260127_025337.mp4"


Get-PCXMediaInformation `
    -Path "C:\Recording seg TestONLOY\bandicam.mp4"

Get-PCXMediaInformation `
    -Path "C:\Recording seg TestONLOY\bandicam.webcam.mp4"

Get-PCXMediaInformation `
    -Path "C:\Recording seg TestONLOY\VID_20260127_025337.mp4"


Get-PCXMediaInformation `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4"
    
Get-PCXMediaInformation `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4"

Get-PCXMediaInformation `
    -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4"





#####################


Edit-PCXRecordingSession `
    -ReferencePath "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4" `
    -SourcePaths @(
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4"
) `
    -OutputDirectory "C:\Recording seg TestONLOY"


Edit-PCXRecordingSession `
    -ReferencePath "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4" `
    -SourcePaths @(
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4",
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4"
) `
    -OutputDirectory "C:\Recording seg TestONLOY"

$allPaths = @(
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.mp4",
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337.mp4",
    "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcam.mp4"
)

$MediaSources = $allPaths | New-PCXMediaSource

$MediaSources |
Select-Object Id, Label, Path |
Format-Table -AutoSize


$MediaSources |
Group-Object Id |
Where-Object Count -gt 1 |
Format-Table Name, Count

Get-PCXMediaInformation -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicam.webcamOriginal.mp4"
Get-PCXMediaInformation -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\bandicamOriginal.mp4" 
Get-PCXMediaInformation -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001\VID_20260127_025337Original.mp4"
Get-PCXMediaInformation -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001 C ShortPauseTRUE\bandicam.mp4"
Get-PCXMediaInformation -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001 C ShortPauseTRUE\bandicam.webcam.mp4"
Get-PCXMediaInformation -Path "C:\Recording seg TestONLOY\RG_20260127_025337_001 C ShortPauseTRUE\VID_20260127_025337.mp4"
Get-PCXMediaInformation -Path "C:\Recording seg TestONLOY\bandicam.mp4"
Get-PCXMediaInformation -Path "C:\Recording seg TestONLOY\bandicam.webcam.mp4"
Get-PCXMediaInformation -Path "C:\Recording seg TestONLOY\VID_20260127_025337.mp4"
Get-PCXMediaInformation -Path 

write-h