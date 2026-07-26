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

Import-Module .\src\Modules\PCXLab.VideoTools