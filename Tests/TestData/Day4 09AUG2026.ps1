
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


Get-ChildItem "$env:TEMP\PCXLab\VideoTools" -Recurse -File -ErrorAction SilentlyContinue

Get-Command Invoke-PCXFFmpegEdit -ErrorAction SilentlyContinue

Get-Content ".\src\Modules\PCXLab.VideoTools\1.1.0\Private\Editing\Invoke-PCXFFmpegEdit.ps1" | Select-String "filter_complex_script|Filter graph preserved|Remove-Item"



Run these three commands only:

git diff --cached --check
git diff --cached --stat
git status --short

Paste those three outputs. Then we'll deal with the commit—no more unnecessary test loops.


Next — keep it simple

First check what changed in the test files:

git diff -- "Tests/TestData/Day3 08AUG2026.ps1"

Then:

Get-Content "Tests/TestData/Day4 09AUG2026.ps1"

If Day 4 is the new test script we want to keep, then simply:

git add -- "Tests/TestData/Day3 08AUG2026.ps1" "Tests/TestData/Day4 09AUG2026.ps1"

Check:

git status --short

Then commit:

git commit -m "test: add Day 4 video editing test"

Finally:

git status

Do not change anything else right now. We have already tested the module and committed the actual code change.


git diff --no-color -- src/Modules/PCXLab.VideoTools/1.1.0/Private/Models/New-PCXEditJobObject.ps1 src/Modules/PCXLab.VideoTools/1.1.0/Public/Editing/Remove-PCXSilence.ps1 src/Modules/PCXLab.VideoTools/1.1.0/Private/Editing/Invoke-PCXFFmpegEdit.ps1

pwsh.exe -ExecutionPolicy Bypass -File "C:\Projects\PCXLab.VideoTools\Run-VideoSilenceRemover.ps1"

Remove-PCXSilence -Path "C:\Videos\Test.mp4"

"C:\Projects\PCXLab.VideoTools\Tools\FFmpeg\bin\ffmpeg.exe" -v error -select_streams a:0 -show_entries stream=sample_rate -of default=noprint_wrappers=1 "C:\Videos\Test.mp4"

Test-Path "C:\Projects\PCXLab.VideoTools\Tools\FFmpeg\bin\ffprobe.exe"

& "C:\Projects\PCXLab.VideoTools\Tools\FFmpeg\bin\ffprobe.exe" -v error -select_streams a:0 -show_entries stream=sample_rate -of default=noprint_wrappers=1 "C:\Videos\Test.mp4"

& "C:\Projects\PCXLab.VideoTools\Tools\FFmpeg\bin\ffprobe.exe" -v error -select_streams a:0 -show_entries stream=sample_rate -of default=noprint_wrappers=1 "C:\Videos\Test-Edited.mp4"

Run these two commands:

& "C:\Projects\PCXLab.VideoTools\Tools\FFmpeg\bin\ffprobe.exe" -v error -select_streams a:0 -show_entries stream=channels,channel_layout -of default=noprint_wrappers=1 "C:\Videos\Test.mp4"

and:

& "C:\Projects\PCXLab.VideoTools\Tools\FFmpeg\bin\ffprobe.exe" -v error -select_streams a:0 -show_entries stream=channels,channel_layout -of default=noprint_wrappers=1 "C:\Videos\Test-Edited.mp4"

We expect something like:


git diff --no-color -- src/Modules/PCXLab.VideoTools/1.1.0/Private/Models/New-PCXEditJobObject.ps1 src/Modules/PCXLab.VideoTools/1.1.0/Public/Editing/Remove-PCXSilence.ps1 src/Modules/PCXLab.VideoTools/1.1.0/Private/Editing/Invoke-PCXFFmpegEdit.ps1

Run just these final commands yourself:

git diff --check

then:

git status --short

Then, if you want one final confirmation of the actual output:

& "C:\Projects\PCXLab.VideoTools\Tools\FFmpeg\bin\ffprobe.exe" -v error -select_streams a:0 -show_entries stream=sample_rate,channels,channel_layout -of default=noprint_wrappers=1 "C:\Videos\Test-Edited.mp4"

We already know what we expect:

sample_rate=48000
channels=2
channel_layout=stereo
Then we review the complete diff once

Use exactly:

git diff --no-color -- src/Modules/PCXLab.VideoTools/1.1.0/Private/Models/New-PCXEditJobObject.ps1 src/Modules/PCXLab.VideoTools/1.1.0/Public/Editing/Remove-PCXSilence.ps1 src/Modules/PCXLab.VideoTools/1.1.0/Private/Editing/Invoke-PCXFFmpegEdit.ps1

Do not ask Cline to modify anything.