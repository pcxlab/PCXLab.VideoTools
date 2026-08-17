Clear-Host

Remove-Module PCXLab.VideoTools -Force
Import-Module .\src\Modules\PCXLab.VideoTools
Get-Module -Name PCXLab.VideoTools
Get-Command -Module PCXLab.VideoTools

Test-PCXVideoTools

Analyze-PCXVideo -Path "C:\Videos\Test.mp4"

Find-PCXSilence -Path "C:\Videos\Test.mp4"


Please run exactly these 4 commands
Test 1
$result = @(
    Find-PCXSilence -Path "C:\Videos\Test.mp4"
)

$result.Count

Expected: 25

Test 2
$result |
Group-Object Classification

Paste the output.

Test 3 (this is the important one)
$result |
Select-Object -First 5 |
ForEach-Object {
    $_.PSTypeNames
}

Paste the output.

Test 4 (VERY important)
(Get-PCXMediaInformation -Path "C:\Videos\Test.mp4").GetType().FullName

and

@(Get-PCXMediaInformation -Path "C:\Videos\Test.mp4").Count


I also want one tiny test

Run:

Find-PCXSilence -Path "C:\Videos\Test.mp4" |
Get-PCXVideoSegments |
Measure-Object

You already did this once and got 51.

Now run this instead:

$Segments = @(
    Find-PCXSilence -Path "C:\Videos\Test.mp4" |
    Get-PCXVideoSegments
)

$Segments.Count

If it prints 51, then Get-PCXVideoSegments is also innocent.



$Analysis = Analyze-PCXVideo -Path "C:\Videos\Test.mp4"

$result |
Select-Object StartSeconds, EndSeconds

$result.Count




Please run these exact commands.

Test 1
$result.Count
Test 2
$result |
ForEach-Object {
    $_.GetType().FullName
} |
Group-Object

Test 3 (MOST IMPORTANT)
$result |
ForEach-Object {

    [PSCustomObject]@{
        TypeNames = $_.PSTypeNames -join ', '
        HasStart  = $_.PSObject.Properties.Match('Start').Count
        HasEnd    = $_.PSObject.Properties.Match('End').Count
        HasSource = $_.PSObject.Properties.Match('SourcePath').Count
    }

} | Format-Table
I now think I know where the bug is


Analyze-PCXVideo -Path "C:\Videos\Test.mp4"

$analysis = Analyze-PCXVideo -Path C:\Videos\Test.mp4

$analysis.Analysis.Silence.Count
$analysis.Analysis.Segments.Count
$analysis.Analysis.SilenceStatistics
$Analysis = Analyze-PCXVideo -Path "C:\Videos\Test.mp4"

Clear-Host
Remove-Module PCXLab.VideoTools -Force
Import-Module .\src\Modules\PCXLab.VideoTools

$Analysis = Analyze-PCXVideo -Path "C:\Videos\Test.mp4"


Analyze-PCXVideo -Path "C:\Videos\Test.mp4"


Analyze-PCXVideo -Path "C:\Videos\Test.mp4"


#################################

After replacing it, run these three tests in order
Test 1
Find-PCXSilence -Path "C:\Videos\Test.mp4" | Measure-Object

Expected:

Count : 25
Test 2
Find-PCXSilence -Path "C:\Videos\Test.mp4" |
Get-PCXVideoSegments |
Measure-Object

Expected:

Count : 45
Test 3 (most important)
$Analysis = Analyze-PCXVideo -Path "C:\Videos\Test.mp4"

$Analysis.Analysis.Silence.Count
$Analysis.Analysis.Segments.Count
$Analysis.Analysis.SilenceStatistics.TotalSilences

Expected:

25
45
25

$raw = Invoke-PCXSilenceDetection -Path "C:\Videos\Test.mp4"

$lines = $raw -split "`r?`n"

"Start Count = $(
    ($lines | Select-String 'silence_start').Count
)"

"End Count = $(
    ($lines | Select-String 'silence_end').Count
)"


Analyze-PCXVideo -Path "C:\Videos\Test.mp4"


#############################

Run these three commands:

Get-PCXSetting -Name 'Analysis.MinimumSilenceDuration'

Find-PCXSilence -Path "C:\Videos\Test.mp4" |
Measure-Object
Find-PCXSilence `
    -Path "C:\Videos\Test.mp4" `
    -MinimumDuration 1 |
Measure-Object



##########################################
Tests I recommend

Run these one at a time.

Test 1 — Basic detection
Find-PCXSilence `
    -Path "C:\Videos\Test.mp4"

Expected:

Returns 25 silence objects (or whatever your test video currently produces).
No errors.
Test 2 — Count
Find-PCXSilence `
    -Path "C:\Videos\Test.mp4" |
Measure-Object

Expected:

Count : 25
Test 3 — Type
Find-PCXSilence `
    -Path "C:\Videos\Test.mp4" |
Get-Member

Expected:

TypeName: PCXLab.Silence
Test 4 — Pipeline
Get-ChildItem C:\Videos\Test.mp4 |
Find-PCXSilence

Should return the same result.

Test 5 — Override settings
Find-PCXSilence `
    -Path "C:\Videos\Test.mp4" `
    -MinimumDuration 5

Should return fewer silence regions than the default.

Test 6 — Noise floor override
Find-PCXSilence `
    -Path "C:\Videos\Test.mp4" `
    -NoiseFloor -25

Should produce different detection results compared to the default.

Test 7 — Verbose
Find-PCXSilence `
    -Path "C:\Videos\Test.mp4" `
    -Verbose

Expected:

VERBOSE: Detected 25 silence region(s) in 'C:\Videos\Test.mp4'.
Test 8 — Analyze-PCXVideo integration (most important)
$Analysis = Analyze-PCXVideo `
    -Path "C:\Videos\Test.mp4"

$Analysis.Analysis.Silence.Count
$Analysis.Analysis.Segments.Count
$Analysis.Analysis.SilenceStatistics

Expected:

Silence count matches Find-PCXSilence.
Segment count matches Get-PCXVideoSegments.
Statistics reflect the silence collection.
Test 9 — Accessor integration (future architecture)

Once your accessor cmdlets are in place:

Analyze-PCXVideo `
    -Path "C:\Videos\Test.mp4" |
Get-PCXSilence |
Measure-Object

Expected:

Count : 25

This confirms the analysis object exposes the silence collection correctly.

##################################################################
Tests I recommend
Test 1 – Find-PCXSilence
Find-PCXSilence `
    -Path "C:\Videos\Test.mp4"

Expected:

No errors
48 silence objects (or whatever is expected for your sample)
Test 2 – Analyze
Analyze-PCXVideo `
    -Path "C:\Videos\Test.mp4"

Expected:

No errors.

Test 3 – Get Silence
Analyze-PCXVideo `
    -Path "C:\Videos\Test.mp4" |
Get-PCXSilence

Expected:

48 silence objects.

Test 4 – Count
Analyze-PCXVideo `
    -Path "C:\Videos\Test.mp4" |
Get-PCXSilence |
Measure-Object

Expected:

Count : 48
Test 5 – Member
Analyze-PCXVideo `
    -Path "C:\Videos\Test.mp4" |
Get-PCXSilence |
Get-Member

Expected:

TypeName: PCXLab.Silence
Test 6 – Segments
Analyze-PCXVideo `
    -Path "C:\Videos\Test.mp4" |
Get-PCXVideoSegments

Expected:

A list of PCXLab.VideoSegment objects.

Important: Based on the current implementation you shared, this test will fail.

Why?

Your current Get-PCXVideoSegments expects:

PCXLab.Silence

objects.

But this command passes:

PCXLab.VideoAnalysis

objects.

So unless you've already updated Get-PCXVideoSegments to act as an accessor (like Get-PCXSilence), you'll get:

InputObject must be a PCXLab.Silence object.

That is expected with the current code.

Test 7 – Current design

This should work:
##########################################################################
Analyze-PCXVideo `
    -Path "C:\Videos\Test.mp4" |
Get-PCXSilence |
Get-PCXVideoSegments

Expected:

Video segments.

Test 8 – Count Segments
Analyze-PCXVideo `
    -Path "C:\Videos\Test.mp4" |
Get-PCXSilence |
Get-PCXVideoSegments |
Measure-Object

Expected:

Count : 82

(or whatever the optimized segment count is expected to be after any future changes).

Test 9 – Statistics
$Analysis = Analyze-PCXVideo `
    -Path "C:\Videos\Test.mp4"

$Analysis.Analysis.SilenceStatistics

Expected:

Total Silences : 48
Short Pauses   : ...
Edit Candidates: ...
Recording Breaks: ...
Test 10 – Pipeline
Get-ChildItem "C:\Videos\Test.mp4" |
Analyze-PCXVideo |
Get-PCXSilence |
Measure-Object

Expected:

Count : 48

$message = "feat(analysis): refactor silence analysis into unified video analysis object

- Simplify Analyze-PCXVideo pipeline
- Return PCXLab.VideoAnalysis object
- Add Get-PCXSilence helper
- Refactor silence detection workflow
- Improve default export path handling
- Clean up diagnostics and debugging code"

git add .

$Analysis = Analyze-PCXVideo `
    -Path "C:\Videos\Test.mp4"

$Analysis |
    Export-PCXVideoAnalysis


    #####################################

    Export
Analyze-PCXVideo `
    -Path "C:\Videos\Test.mp4" |
Export-PCXVideoAnalysis
Import
Import-PCXVideoAnalysis `
    -Path "C:\Videos\Test-Analysis.json"

Expected:

SourcePath
Created
ModuleVersion
Media
Analysis
Test the pipeline

This is the important one.

Import-PCXVideoAnalysis `
    -Path "C:\Videos\Test-Analysis.json" |
Get-PCXSilence |
Measure-PCXSilence

#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

$Analysis = Import-PCXVideoAnalysis `
    -Path "C:\Videos\Test-Analysis.json"

$Analysis.Analysis.Silence[0].PSTypeNames


#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

You should get exactly the same statistics as when you analyzed the MP4 directly.

Test EditPoints
Import-PCXVideoAnalysis `
    -Path "C:\Videos\Test-Analysis.json" |
Get-PCXSilence |
Get-PCXEditPoint

Should produce the same 11 edit points.

Test Premiere Markers
Import-PCXVideoAnalysis `
    -Path "C:\Videos\Test-Analysis.json" |
Get-PCXSilence |
Export-PCXPremiereMarkers

No FFmpeg should run.

Test Premiere Edit Points
Import-PCXVideoAnalysis `
    -Path "C:\Videos\Test-Analysis.json" |
Get-PCXSilence |
Export-PCXPremiereEditPoints


"C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253-Analysis.json"

Import-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253-Analysis.json" |
Get-PCXSilence |
Export-PCXPremiereMarkers


Import-PCXVideoAnalysis `
    -Path "C:\Recording seg TestONLOY\20260127 TEST Recording once\RG_20260127_025337_004\bandicam 2026-01-27 02-53-49-253-Analysis.json" |
Get-PCXSilence |
Export-PCXPremiereEditPoints



Again, no FFmpeg should run.

$Analysis = Import-PCXVideoAnalysis `
    -Path "C:\Videos\Test-Analysis.json"

$Analysis.Analysis.Silence[0].PSTypeNames

#########################################

Then run the important pipeline:

Import-PCXVideoAnalysis `
    -Path "C:\Videos\Test-Analysis.json" |
Get-PCXSilence |
Measure-PCXSilence

If that works, then continue with:

Import-PCXVideoAnalysis `
    -Path "C:\Videos\Test-Analysis.json" |
Get-PCXSilence |
Get-PCXEditPoint

and finally:

Import-PCXVideoAnalysis `
    -Path "C:\Videos\Test-Analysis.json" |
Get-PCXSilence |
Export-PCXPremiereMarkers

Import-PCXVideoAnalysis `
    -Path "C:\Videos\Test-Analysis.json" |
Get-PCXSilence |
Export-PCXPremiereEditPoints

If these pass, your Analysis.json cache will be functionally equivalent to re-running Analyze-PCXVideo, which is exactly the behavior you want for the long-term cache architecture.





Run:

$Analysis = Import-PCXVideoAnalysis `
    -Path "C:\Videos\Test-Analysis.json"

$Analysis.Analysis.Silence[0].Start.GetType().FullName

It should return:

System.TimeSpan

instead of:

System.Management.Automation.PSCustomObject

Then rerun:

Import-PCXVideoAnalysis `
    -Path "C:\Videos\Test-Analysis.json" |
Get-PCXSilence |
Get-PCXEditPoint

I expect that test to pass.


PowerShell -ExecutionPolicy Bypass -File "C:\Projects\PCXLab.VideoTools\Run-VideoAnalysis.ps1"







