Clear-Host

Remove-Module PCXLab.VideoTools -Force
Import-Module .\src\Modules\PCXLab.VideoTools
Get-Module -Name PCXLab.VideoTools
Get-Command -Module PCXLab.VideoTools


Get-ChildItem -Path "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools\1.1.0"  -Filter "Invoke-PCXFFmpegEdit.ps1" -Recurse -File
Get-ChildItem -Path "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools\1.1.0"  -Filter "ConvertTo-PCXConcatFilter.ps1" -Recurse -File


git restore src\Modules\PCXLab.VideoTools\1.1.0\Private\Models\New-PCXEditJobObject.ps1


###########################################

Step 2 - Verify the new setting is loaded

Run:

Get-PCXSetting -Name "Audio.Normalize"

Expected output:

False

Then run:

Get-PCXSetting -Name "Audio.Compression"

Expected:

False

Then:

Get-PCXSetting -Name "Audio.RepairChannels"

Expected:

False

If any of these fail, stop and tell me the error.

Step 3 - Run the test video

Use your test file:

Remove-PCXSilence -Path "C:\Videos\Test.mp4"
Step 4 - Tell me the result

I want to know:
git add .
git commit -m "feat(editing): integrate configurable audio processing into editing pipeline"


##########################

Clear-Host

Remove-Module PCXLab.VideoTools -Force -ErrorAction SilentlyContinue
Import-Module .\src\Modules\PCXLab.VideoTools -Force

Test-PCXVideoTools

Get-PCXMediaInformation -Path "C:\Videos\Test.mp4"

Find-PCXSilence -Path "C:\Videos\Test.mp4"

Remove-PCXSilence -Path "C:\Videos\Test.mp4"

Get-PCXMediaInformation -Path "C:\Videos\Test-Edited.mp4"

Get-PCXAudioInformation -Path "C:\Videos\Test-Edited.mp4"

Get-Item "C:\Videos\Test-Edited.mp4" |
    Select-Object FullName, Length, LastWriteTime

git status --short


Get-PCXSetting -Name "Audio.Normalize"

Get-PCXSetting -Name "Audio.Compression"

Get-PCXSetting -Name "Audio.RepairChannels"

Get-PCXSetting -Name "Audio"

Get-Content ".\src\Modules\PCXLab.VideoTools\1.1.0\Settings.json"


Get-PCXAudioInformation -Path "C:\Videos\Test.mp4"

Get-PCXAudioInformation -Path "C:\Videos\Test-Edited.mp4"

Get-Content ".\src\Modules\PCXLab.VideoTools\1.1.0\Private\Converters\ConvertTo-PCXAudioFilter.ps1"

Get-Content ".\src\Modules\PCXLab.VideoTools\1.1.0\Private\Editing\Invoke-PCXFFmpegEdit.ps1"

Get-Content ".\src\Modules\PCXLab.VideoTools\1.1.0\Public\Editing\Remove-PCXSilence.ps1"