
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
Automatically publish timeline artifacts and centralize RecordingSession naming

- Automatically export VideoSegments, PremiereMarkers and PremiereEditPoints
- Reuse in-memory VideoSegment objects without rerunning processing
- Centralize RecordingSession artifact naming via Get-PCXArtifactPath
- Prefix RecordingSession artifacts with recording group folder
- Remove legacy RecordingSession filename special case
- Update artifact path tests
"@

git add .

git commit -m $message

git push

Import-Module "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools" -Force

Edit-PCXRecordingSession `
    -ReferencePath "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253.mp4" `
    -SourcePaths @(
    "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\VID_20260127_025337.mp4",
    "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253.mp4.webcam.mp4"
)



git restore src/Modules/PCXLab.VideoTools/1.1.0/Public/Synchronization/Edit-PCXRecordingSession.ps1


git diff src/Modules/PCXLab.VideoTools/1.1.0/Public/Synchronization/Edit-PCXRecordingSession.ps1


Import-PCXRecordingSession `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\RG_20260127_025337_004-RecordingSession.json" |
Select-Object -ExpandProperty Timeline |
Select-Object -ExpandProperty SourceOffsets |
Select-Object SourceId, Method, OffsetSeconds


Get-Content `
"C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\RG_20260127_025337_004-RecordingSession.json" `
-Raw |
ConvertFrom-Json |
Select-Object -ExpandProperty Timeline |
Select-Object -ExpandProperty SourceOffsets |
Select-Object SourceId, Method, OffsetSeconds

Get-Command *RecordingSession*

Get-Command -Module PCXLab.VideoTools *RecordingSession*


Get-Content `
"C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\RG_20260127_025337_004-RecordingSession.json" `
-Raw |
ConvertFrom-Json |
Select-Object -ExpandProperty Timeline |
Select-Object -ExpandProperty SourceOffsets |
Select-Object SourceId, Method, OffsetSeconds


Get-Content `
"C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\RG_20260127_025337_004-RecordingSession.json" `
-First 40


$media = Build-PCXMediaSourcesFromPaths `
    -ReferencePath "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253.mp4" `
    -SourcePaths @(
        "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\VID_20260127_025337.mp4",
        "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253.mp4.webcam.mp4"
    )

$media |
Select-Object Id, LinkedSourceId, Path


(Get-Content `
"C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\RG_20260127_025337_004-RecordingSession.json" `
-Raw |
ConvertFrom-Json).MediaSynchronization[0].Sources |
Select-Object Id, LinkedSourceId, Path



$sourceByFileName = @{}




$media = Build-PCXMediaSourcesFromPaths `
    -ReferencePath "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253.mp4" `
    -SourcePaths @(
        "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\VID_20260127_025337.mp4",
        "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253.mp4.webcam.mp4"
    )

$media | Select-Object Id, LinkedSourceId




git add .

git commit -m "Add linked recording source synchronization support"