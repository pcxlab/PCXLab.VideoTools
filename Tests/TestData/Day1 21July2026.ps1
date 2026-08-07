Clear-Host

Remove-Module PCXLab.VideoTools -Force
Import-Module .\src\Modules\PCXLab.VideoTools
Get-Module -Name PCXLab.VideoTools
Get-Command -Module PCXLab.VideoTools

Test-PCXVideoTools

Get-ChildItem .\src\Modules\PCXLab.VideoTools\1.0.0\Public -Recurse

tree .\src\Modules\PCXLab.VideoTools\1.0.0 /f
tree /f

Get-Content .\src\Modules\PCXLab.VideoTools\1.0.0\PCXLab.VideoTools.psm1

Get-Content .\src\Modules\PCXLab.VideoTools\1.0.0\PCXLab.VideoTools.psd1


Get-Content .\src\Modules\PCXLab.VideoTools\1.0.0\Public\Utilities\Test-PCXVideoTools.ps1

Get-ChildItem .\src\Modules\PCXLab.VideoTools\1.0.0\Public -Filter *.ps1 -Recurse | Select-Object Name, BaseName, FullName


Get-PCXVideoInformation "C:\Videos\Test.mp4"

tree /f "C:\Users\Admin\Downloads\Compressed\ffmpeg-8.1.2-essentials_build\ffmpeg-8.1.2-essentials_build"


Get-PCXVideoInformation "C:\Videos\Test.mp4" | Format-List

Get-PCXAudioInformation "C:\Videos\Test.mp4"

Get-PCXAudioInformation "C:\Videos\Test.mp4" | Format-List *

Remove-Module PCXLab.VideoTools -Force
Import-Module .\src\Modules\PCXLab.VideoTools

Get-PCXMediaInformation "C:\Videos\Test.mp4" | Format-List *

$Media = Get-PCXMediaInformation "C:\Videos\Test.mp4"

$Media.Video

$Media.Audio

$Media.Video.Width

$Media.Audio.SampleRate


Remove-Module PCXLab.VideoTools -Force
Import-Module .\src\Modules\PCXLab.VideoTools

Get-PCXAudioInformation "C:\Videos\Test.mp4" | Format-List *

$Media = Invoke-PCXFFprobe "C:\Videos\Test.mp4"

Get-PCXSubtitleStreams -InputObject $Media


cls

Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue

Import-Module .\src\Modules\PCXLab.VideoTools -Force

Get-PCXVideoInformation "C:\Videos\Test.mp4" | Format-List *


Get-Content "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools\1.0.0\Private\Models\New-PCXMediaInformationObject.ps1"

Get-ChildItem "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools\1.0.0\Private\Models"

cls

Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue

Import-Module .\src\Modules\PCXLab.VideoTools -Force

Get-PCXMediaInformation "C:\Videos\Test.mp4" | Format-List *


vds.exe


Get-ChildItem "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools\1.0.0\Private\Models" |
Select-Object Name



Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue

Import-Module .\src\Modules\PCXLab.VideoTools -Force

Get-PCXAudioInformation "C:\Videos\Test.mp4" | Format-List *

Get-PCXMediaInformation "C:\Videos\Test.mp4" | Format-List *


########################################
cls
Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue

Import-Module .\src\Modules\PCXLab.VideoTools -Force

Get-PCXVideoInformation "C:\Videos\Test.mp4" | Format-List *

Get-PCXMediaInformation "C:\Videos\Test.mp4" | Format-List *

Get-Content "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools\1.0.0\Private\Converters\ConvertTo-PCXVideoInformation.ps1"
Get-Content "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools\1.0.0\Private\Converters\ConvertTo-PCXVideoInformation.ps1"
Get-Content "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools\1.0.0\Public\Analysis\Get-PCXMediaInformation.ps1"

Get-ChildItem "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools\1.0.0\Private\Models"

Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue

Import-Module .\src\Modules\PCXLab.VideoTools -Force

Get-PCXVideoInformation "C:\Videos\Test.mp4" | Format-List *

Get-PCXMediaInformation "C:\Videos\Test.mp4" | Format-List *


cls
Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue

Import-Module .\src\Modules\PCXLab.VideoTools -Force

Get-PCXVideoInformation C:\Videos\Test.mp4
Get-PCXAudioInformation C:\Videos\Test.mp4


Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue

Import-Module .\src\Modules\PCXLab.VideoTools\1.1.0 -Force
Get-Module PCXLab.VideoTools

Get-PCXVideoInformation C:\Videos\Test.mp4
Get-PCXAudioInformation C:\Videos\Test.mp4
Get-PCXAudioInformation C:\Videos\Test.mp4



Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue

Import-Module .\src\Modules\PCXLab.VideoTools -Force

Get-PCXAudioInformation C:\Videos\Test.mp4

Get-PCXSubtitleInformation C:\Videos\Test.mp4 | Format-List *



Run:
Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue
Import-Module .\src\Modules\PCXLab.VideoTools -Force

Get-PCXMediaInformation C:\Videos\Test.mp4 | Format-List *

cls
Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue
Import-Module .\src\Modules\PCXLab.VideoTools -Force

Get-PCXMediaStreams C:\Videos\Test.mp4
Get-PCXMediaInformation C:\Videos\Test.mp4

Get-PCXVideoInformation | Format-List *

Get-PCXVideoInformation | Format-List


Describe 'Get-PCXVideoInformation' {

    It 'Returns the correct type' {

        $Video = Get-PCXVideoInformation C:\Videos\Test.mp4

        $Video.PSTypeNames[0] |
        Should -Be 'PCXLab.VideoInformation'

    }

}


$Video.Width | Should -Be 1360

$Video.Height | Should -Be 768

$Video.VideoCodec | Should -Be 'h264'

Get-Module Pester -ListAvailable | Sort-Object Version -Descending

#IMPORTENT
Install-Module Pester -Scope CurrentUser -Force -SkipPublisherCheck

Invoke-Pester .\Tests\Public\Get-PCXVideoInformation.Tests.ps1


$TestVideo = Join-Path $PSScriptRoot '..\TestData\Test.mp4'

$TestVideo = Join-Path $PSScriptRoot '.\Tests\TestData\Test.mp4'
$TestVideo = (Resolve-Path $TestVideo).Path

$Video = Get-PCXVideoInformation $TestVideo


$TestVideo = Join-Path $PSScriptRoot '..\TestData\Test.mp4'
$TestVideo = (Resolve-Path $TestVideo).Path


Invoke-Pester .\Tests


Invoke-Pester .\Tests


$s = New-PCXSilenceObject `
    -Start ([TimeSpan]::FromSeconds(15.32)) `
    -End ([TimeSpan]::FromSeconds(22.94)) `
    -DurationSeconds 7.62

$s | Format-List *


Get-ChildItem `
    .\src\Modules\PCXLab.VideoTools\1.1.0\Private\Models

Get-Command New-PCXVideoInformationObject

Get-Command New-PCXSilenceObject

get-command -module PCXLab.VideoTools

    
cls
Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue

Import-Module .\src\Modules\PCXLab.VideoTools -Force

Get-Command -Module PCXLab.VideoTools | Sort-Object Name



Test-PCXVideoTools

Get-PCXVideoInformation "C:\Videos\Test.mp4"

Get-PCXAudioInformation "C:\Videos\Test.mp4"

Get-PCXMediaInformation "C:\Videos\Test.mp4"

Get-PCXMediaStreams "C:\Videos\Test.mp4"


Find-PCXSilence "C:\Videos\Test.mp4"

Find-PCXSilence "C:\Videos\Test.mp4" |
Measure-PCXSilence

Find-PCXSilence "C:\Videos\Test.mp4" |
Get-PCXEditPoint

Find-PCXSilence "C:\Videos\Test.mp4" |
Export-PCXSilence

#Import-PCXSilence Test-Silence.json

Import-PCXSilence "C:\Videos\Test-Silence.json"

Find-PCXSilence "C:\Videos\Test.mp4" |
Get-PCXEditPoint |
Export-PCXEditPoint

Import-PCXEditPoint "C:\Videos\Test-EditPoints.json"

#8 
Find-PCXSilence "C:\Videos\Test.mp4" |
Export-PCXPremiereMarkers

Find-PCXSilence "C:\Videos\Test.mp4" |
Export-PCXPremiereEditPoints

#9
Get-ChildItem C:\Videos\Test.mp4 |
Find-PCXSilence |
Get-PCXEditPoint |
Export-PCXEditPoint

Invoke-Pester .\Tests


$Commnet = "feat(editpoints): implement edit point analysis and export pipeline

- Added Get-PCXEditPoint
- Added Export/Import-PCXEditPoint
- Added edit point rules via Settings.json
- Added New-PCXExportDocument helper
- Added Get-PCXModuleInfo/Version helpers
- Added default output path support
- Refactored export pipeline
- Added initial Pester coverage"

Analyze-PCXVideo "C:\Videos\Test.mp4"

#AI Impliemntation

Get-ChildItem `
    .\src\Modules\PCXLab.VideoTools\1.1.0 `
    -Recurse `
    -Filter *.ps1 |
Sort-Object FullName |
ForEach-Object {

    [PSCustomObject]@{

        Folder = $_.Directory.Name

        Name   = $_.BaseName

        Path   = $_.FullName.Replace(
            (Resolve-Path '.\src\Modules\PCXLab.VideoTools\1.1.0').Path + '\',
            ''
        )

    }

}


#


Get-ChildItem `
    .\src\Modules\PCXLab.VideoTools\1.1.0 `
    -Recurse `
    -Filter *.ps1 |
Sort-Object FullName |
Select-Object FullName


Get-PCXVideoInformation -Path C:\Videos\Test.mp4

Clear-Host

Remove-Module PCXLab.VideoTools #-Force
Import-Module .\src\Modules\PCXLab.VideoTools
Get-Module -Name PCXLab.VideoTools
Get-Command -Module PCXLab.VideoTools


$Segments |
Optimize-PCXVideoSegments -Path C:\Videos\Test.mp4

Find-PCXSilence "C:\Videos\Test.mp4" |
Get-PCXVideoSegments


Find-PCXSilence "C:\Videos\Test.mp4" |
Get-PCXVideoSegments |
Measure-Object


Find-PCXSilence "C:\Videos\Test.mp4" |
Get-PCXVideoSegments |
Group-Object Action


Find-PCXSilence "C:\Videos\Test.mp4" |
Get-PCXVideoSegments |
Sort-Object Start |
Format-Table Start, End, Action


Find-PCXSilence "C:\Videos\Test.mp4" |
Get-PCXVideoSegments |
Format-Table Start, End, Duration, Action


$Filter = Find-PCXSilence C:\Videos\Test.mp4 |
Get-PCXVideoSegments |
New-PCXFFmpegConcatFilter

$Filter


Remove-PCXSilence `
    -Path "C:\Videos\Test.mp4"


Get-Item "C:\Videos\Test.mp4" |
Remove-PCXSilence

$result = Remove-PCXSilence `
    -Path "C:\Videos\Test.mp4"

$result.GetType().FullName

Remove-Module PCXLab.VideoTools -Force
cls
Import-Module .\src\Modules\PCXLab.VideoTools

Remove-PCXSilence `
    -Path "C:\Videos\Test.mp4"