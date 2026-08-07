Find-PCXSilence `
    -Path C:\Video.mp4 `
    -MinimumDuration 2 `
    -NoiseFloor -35

Find-PCXSilence `
    -Path 'C:\Videos\Test.mp4' `
    -MinimumDuration 2 `
    -NoiseFloor -35
    
Find-PCXSilence `
    -Path 'C:\Videos\Tutorial.mp4' `
    -MinimumDuration 2 `
    -NoiseFloor -35

#################################

Clear-Host

Remove-Module PCXLab.VideoTools -Force
Import-Module .\src\Modules\PCXLab.VideoTools

Find-PCXSilence -Path 'C:\Videos\Test.mp4' |
Export-PCXPremiereEditPoints `
    -OutputPath 'C:\Videos\Tutorial-Selected.jsx'


Find-PCXSilence -Path 'C:\Videos\Test.mp4' |
Export-PCXPremiereEditPoints `
    -OutputPath 'C:\Videos\Tutorial-All.jsx' `
    -TrackMode All


Get-ChildItem -Recurse -Include *.ps1, *.psm1 |
Select-String "ConvertTo-PCXPremiereEditPointScript"


Get-ChildItem -Path .\src\Modules\PCXLab.VideoTools\1.1.0\ -Recurse -Include *.ps1, *.psm1, *.psd1, *.md |
Select-String -Pattern '\bAllTracks\b' |
Select-Object Path, LineNumber, Line

Get-ChildItem -Path .\src\Modules\PCXLab.VideoTools\1.1.0\  -Recurse -Include *.ps1, *.psm1, *.psd1, *.md |
Select-String -Pattern '\bcutAllTracks\b' |
Select-Object Path, LineNumber, Line


Get-ChildItem -Path .\src\Modules\PCXLab.VideoTools\1.1.0\ -Recurse -Include *.ps1, *.psm1, *.psd1, *.md |
Select-String -Pattern '\bTrackMode\b' |
Select-Object Path, LineNumber, Line


Get-ChildItem -Path .\src\Modules\PCXLab.VideoTools\1.1.0\ -Recurse -Include *.ps1, *.psm1, *.psd1, *.md |
Select-String -Pattern '\bAllTracks\b' |
Group-Object Path |
ForEach-Object {
    "`n$($_.Name)"
    $_.Group | ForEach-Object {
        "  Line $($_.LineNumber): $($_.Line.Trim())"
    }
}


Get-ChildItem -Path .\src\Modules\PCXLab.VideoTools\1.1.0\ -Recurse -Include *.ps1, *.psm1, *.psd1, *.md |
Select-String -Pattern '\bcutAllTracks\b' |
Group-Object Path |
ForEach-Object {
    "`n$($_.Name)"
    $_.Group | ForEach-Object {
        "  Line $($_.LineNumber): $($_.Line.Trim())"
    }
}

Get-ChildItem -Path .\src\Modules\PCXLab.VideoTools\1.1.0\ -Recurse -Include *.ps1, *.psm1, *.psd1, *.md |
Select-String -Pattern '\bTrackMode\b' |
Group-Object Path |
ForEach-Object {
    "`n$($_.Name)"
    $_.Group | ForEach-Object {
        "  Line $($_.LineNumber): $($_.Line.Trim())"
    }
}

Find-PCXSilence -Path 'C:\Videos\Test.mp4' |
Select-Object -First 1 |
Format-List *


################ TESTS BEFore commits 

#Test 1 - Edit Points (Automatic Output) ⭐ New Feature
Find-PCXSilence -Path 'C:\Videos\Test.mp4' |
Export-PCXPremiereEditPoints

Expected:
C:\Videos\Test-PremiereEditPoints.jsx

Test 2 - Edit Points (All Tracks)
Find-PCXSilence -Path 'C:\Videos\Test.mp4' |
Export-PCXPremiereEditPoints `
    -TrackMode All
Expected:
C:\Videos\Test-PremiereEditPoints-AllTracks.jsx
Test 3 - Edit Points (Explicit OutputPath)
Find-PCXSilence -Path 'C:\Videos\Test.mp4' |
Export-PCXPremiereEditPoints `
    -OutputPath 'C:\Videos\MyEditPoints.jsx'
Expected:
C:\Videos\MyEditPoints.jsx
This confirms that a user-specified path overrides the automatic naming.
Test 4 - Markers (Automatic Output)
Find-PCXSilence -Path 'C:\Videos\Test.mp4' |
Export-PCXPremiereMarkers
Expected:
C:\Videos\Test-PremiereMarkers.jsx
Test 5 - Markers (Include Short Pause)
Find-PCXSilence -Path 'C:\Videos\Test.mp4' |
Export-PCXPremiereMarkers `
    -IncludeShortPause
Expected:
C:\Videos\Test-PremiereMarkers-ShortPause.jsx
Test 6 - Markers (Explicit OutputPath)
Find-PCXSilence -Path 'C:\Videos\Test.mp4' |
Export-PCXPremiereMarkers `
    -OutputPath 'C:\Videos\MyMarkers.jsx'
Expected:
C:\Videos\MyMarkers.jsx
One extra test (important)
Since we introduced SourcePath into PCXLab.Silence, let's verify it's actually there:
Find-PCXSilence -Path 'C:\Videos\Test.mp4' |
Select-Object -First 1 |
Format-List SourcePath, Start, End, Classification
Expected:
SourcePath     : C:\Videos\Test.mp4
Start          : ...
End            : ...
Classification : ...



Find-PCXSilence `
    -Path C:\Videos\Test.mp4 |
Export-PCXSilence `
    -OutputPath C:\Videos\Test.silence.json


Import-PCXSilence `
    -Path C:\Videos\Test.silence.json


Import-PCXSilence `
    -Path C:\Videos\Test.silence.json |
Export-PCXPremiereMarkers


Import-PCXSilence `
    -Path C:\Videos\Test.silence.json |
Export-PCXPremiereEditPoints


Import-PCXSilence "C:\Videos\Test.silence.json" |
Get-PCXSilence


Import-PCXSilence "C:\Videos\Test.silence.json" |
Get-PCXSilence


Get-Command New-PCXSilenceObject -Syntax

(Get-Command New-PCXSilenceObject).Parameters.Keys

Import-PCXSilence "C:\Videos\Test.silence.json"

Find-PCXSilence -Path "C:\Videos\Test.mp4"

Import-PCXSilence "C:\Videos\Test.silence.json" |
Get-Member

Remove-Module PCXLab.VideoTools -ErrorAction Ignore

Import-Module .\src\Modules\PCXLab.VideoTools -Force



#################################

Clear-Host 

Remove-Module PCXLab.VideoTools -Force
Import-Module .\src\Modules\PCXLab.VideoTools



Find-PCXSilence "C:\Videos\Test.mp4" |
Measure-PCXSilence


Find-PCXSilence "C:\Videos\Test.mp4" |
Get-PCXEditPoint


Find-PCXSilence "C:\Videos\Test.mp4" |
Get-PCXEditPoint



Get-ChildItem -Path .\src\Modules\PCXLab.VideoTools\1.1.0\  -Recurse -Include *.ps1, *.psm1, *.psd1, *.md |
Select-String -Pattern '\bConvertFrom-Json\b' |
Select-Object Path, LineNumber, Line
 
$finder = "\bAnalysis.EditPoints\b"

Get-ChildItem -Path .\src\Modules\PCXLab.VideoTools\1.1.0\  -Recurse -Include *.ps1, *.psm1, *.psd1, *.md |
Select-String -Pattern $finder |
Select-Object Path, LineNumber, Line


###################

Test 1
Find-PCXSilence "C:\Videos\Test.mp4" |
Get-PCXEditPoint
Verify:
Returns PCXLab.EditPoint
Reason comes from Settings.json
Confidence comes from Settings.json
Disabled rules are ignored
Test 2
Find-PCXSilence "C:\Videos\Test.mp4" |
Get-PCXEditPoint |
Export-PCXEditPoint `
    -Path .\EditPoints.json
Verify:
File exists
JSON is valid
SchemaVersion
ModuleVersion
GeneratedOn
EditPoints collection
Test 3
Import-PCXEditPoint `
    -Path .\EditPoints.json
Verify
Get-Member
shows
PSTypeName : PCXLab.EditPoint
Test 4 (Most Important)
This is the one many people forget.
$Original =
Find-PCXSilence "C:\Videos\Test.mp4" |
Get-PCXEditPoint

$Original |
Export-PCXEditPoint `
    -Path .\EditPoints.json

$Imported =
Import-PCXEditPoint `
    -Path .\EditPoints.json
Then compare.
For example:
Compare-Object `
    $Original `
    $Imported `
    -Property `
    SourcePath,
StartSeconds,
EndSeconds,
DurationSeconds,
Classification,
Reason,
Confidence
There should be no differences.
If there are no differences, your export/import is effectively lossless for those properties.


Compare-Object `
    -ReferenceObject $Original `
    -DifferenceObject $Imported `
    -Property `
    Source,
SourcePath,
StartSeconds,
EndSeconds,
DurationSeconds,
Classification,
Reason,
Confidence


Verify the object type
Also check that the imported objects are the correct custom type:
$Imported | Get-Member
or
$Imported[0].PSTypeNames