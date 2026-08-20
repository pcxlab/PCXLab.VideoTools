
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
Add black frame detection with VideoSegment pipeline integration

- Added Find-PCXBlackFrames
- Added PCXLab.BlackFrame model
- Added FFmpeg blackdetect parser
- Integrated BlackFrame with Get-PCXVideoSegments
- Reused existing JSON, Premiere JSX and rendering pipeline
- Added regression tests
"@

git add .

git commit -m $message

git push

Get-Content `
    .\src\Modules\PCXLab.VideoTools\1.1.0\Public\Synchronization\Get-PCXRecordingSession.ps1

Test-PCXRecordingSessionCache -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\RG_20260127_025337_004-RecordingSession.json"

Test-Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\RG_20260127_025337_004-RecordingSession.json"

Get-Item "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\RG_20260127_025337_004-RecordingSession.json"


Remove-Item "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\RG_20260127_025337_004-RecordingSession.json"

Test-Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\RG_20260127_025337_004-RecordingSession.json"


Edit-PCXRecordingSession `
    -ReferencePath "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253.mp4" `
    -SourcePaths @(
    "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\VID_20260127_025337.mp4",
    "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253.mp4.webcam.mp4"
)

Remove-Module PCXLab.VideoTools -Force
Import-Module .\src\Modules\PCXLab.VideoTools -Force


git restore `
    .\src\Modules\PCXLab.VideoTools\1.1.0\Public\Synchronization\Sync-PCXMedia.ps1 `
    .\src\Modules\PCXLab.VideoTools\1.1.0\Private\Synchronization\Resolve-PCXLinkedSourceOffsets.ps1

git diff

Select-String `
    -Path .\src\Modules\PCXLab.VideoTools\1.1.0\Private\Synchronization\Resolve-PCXLinkedSourceOffsets.ps1 `
    -Pattern "LinkedSourceId -eq \$ReferenceSource.Id"



Find-PCXSilence -Path 'C:\Videos\Test.mp4' |
Export-PCXPremiereMarkers `
    -OutputPath 'C:\Videos\Tutorial-SilenceMarkers.jsx'

Find-PCXSilence -Path 'C:\Videos\Test.mp4' |
Export-PCXPremiereMarkers `
    -OutputPath 'C:\Videos\Tutorial-SilenceMarkersIncludeShortPause.jsx' `
    -IncludeShortPause

Find-PCXSilence -Path 'C:\Videos\Tutorial.mp4' |
Export-PCXPremiereMarkers `
    -OutputPath 'C:\Videos\Tutorial-SilenceMarkers.jsx' `
    -IncludeShortPause

Find-PCXSilence -Path 'C:\Videos\Test.mp4' |
Export-PCXPremiereEditPoints `
    -OutputPath 'C:\Videos\Tutorial-EditPoints.jsx'


cd C:\Projects\PCXLab.VideoTools

pwsh -Command "
Import-Module 'C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools\1.1.0\PCXLab.VideoTools.psd1' -Force

`$r = @(Find-PCXBlackFrames -Path 'Tests\TestData\Test.mp4' -Verbose)

Write-Host 'Count:' `$r.Count

if (`$r.Count -gt 0) {
    Write-Host 'Type:' `$r[0].PSTypeNames[0]
    `$r | Format-List *
}
else {
    Write-Host 'No black frames returned.'
}
"


"C:\Projects\PCXLab.VideoTools\Tools\FFmpeg\bin\ffmpeg.exe" -hide_banner -nostats `
    -i "Tests\TestData\Test.mp4" `
    -vf "blackdetect=d=0.5:pic_th=0.98" `
    -an -f null -


& "C:\Projects\PCXLab.VideoTools\Tools\FFmpeg\bin\ffmpeg.exe" `
    -hide_banner `
    -nostats `
    -i "Tests\TestData\Test.mp4" `
    -vf "blackdetect=d=0.5:pic_th=0.98" `
    -an `
    -f null `
    -

& "C:\Projects\PCXLab.VideoTools\Tools\FFmpeg\bin\ffmpeg.exe" `
    -hide_banner `
    -nostats `
    -i "Tests\TestData\Test.mp4" `
    -vf "blackdetect=d=0.5:pic_th=0.10" `
    -an `
    -f null `
    -


    
Remove-Module PCXLab.VideoTools -Force
Import-Module .\src\Modules\PCXLab.VideoTools -Force


Invoke-Pester -Path Tests/Public/Find-PCXBlackFrames.Tests.ps1

Invoke-Pester -Path Tests/Public/Find-PCXBlackFrames.Tests.ps1 -Output Detailed

Invoke-Pester -Path Tests/Public -Output Detailed

Get-Content .\src\Modules\PCXLab.VideoTools\1.1.0\Private\Converters\ConvertTo-PCXBlackFrame.ps1
code .\src\Modules\PCXLab.VideoTools\1.1.0\Private\Converters\ConvertTo-PCXBlackFrame.ps1

git show --stat HEAD

##############################

1. Test black frame detection
Find-PCXBlackFrames `
    -Path "C:\Videos\Test.mp4"
You should see one or more PCXLab.BlackFrame objects.
2. View the detected black frames
Find-PCXBlackFrames `
    -Path "C:\Videos\Test.mp4" |
Format-Table `
    Start,
    End,
    DurationSeconds -AutoSize
This lets you verify that the detections make sense.
3. Convert detections into VideoSegments
Find-PCXBlackFrames `
    -Path "C:\Videos\Test.mp4" |
Get-PCXVideoSegments
You should get a mixture of:
Keep
Remove
segments.
4. Inspect the generated timeline
Find-PCXBlackFrames `
    -Path "C:\Videos\Test.mp4" |
Get-PCXVideoSegments |
Format-Table `
    SegmentType,
    Start,
    End,
    Duration -AutoSize
This is the first place I would look before rendering.
5. Export Premiere markers
Find-PCXBlackFrames `
    -Path "C:\Videos\Test.mp4" |
Get-PCXVideoSegments |
Export-PCXPremiereMarkers
Verify the JSX file opens correctly in Premiere.
6. Export Premiere edit points
Find-PCXBlackFrames `
    -Path "C:\Videos\Test.mp4" |
Get-PCXVideoSegments |
Export-PCXPremiereEditPoints
7. Export VideoSegments JSON
Find-PCXBlackFrames `
    -Path "C:\Videos\Test.mp4" |
Get-PCXVideoSegments |
Export-PCXVideoSegment
Inspect the JSON to ensure the timeline is correct.
8. Render the edited video
Finally:
Find-PCXBlackFrames `
    -Path "C:\Videos\Test.mp4" |
Get-PCXVideoSegments |
Edit-PCXVideoSegments
This should create an edited video with the detected black sections removed.



cd C:\Projects\PCXLab.VideoTools\Tools\FFmpeg\bin\  
cd C:\Projects\PCXLab.VideoTools\Tools\FFmpeg\bin\ffmpeg.exe


$ffmpeg = "C:\Projects\PCXLab.VideoTools\Tools\FFmpeg\bin\ffmpeg.exe"
$ffmpeg = (Get-Command ffmpeg).Source

& $ffmpeg `
-i "F:\Recordings\20260318 ChatGPT Can make mistake\RG_20260318_233950_004\bandicam 2026-03-18 23-43-48-855.mp4.webcam.mp4" `
-vf "blackdetect=d=0.5:pix_th=0.10:pic_th=0.98" `
-an `
-f null `
-


Get-ChildItem "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools\1.1.0" `
-Recurse `
-Filter "Invoke-PCXFFmpeg.ps1"


Get-ChildItem "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools\1.1.0" `
-Recurse `
-Filter "Find-PCXBlackFrames.ps1"


& "C:\Projects\PCXLab.VideoTools\Tools\FFmpeg\bin\ffmpeg.exe" `
-i "F:\Recordings\20260318 ChatGPT Can make mistake\RG_20260318_233950_004\bandicam 2026-03-18 23-43-48-855.mp4.webcam.mp4" `
-vf "blackdetect=d=0.5:pix_th=0.10" `
-an `
-f null `
- 2>&1