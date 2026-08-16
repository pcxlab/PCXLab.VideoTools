Describe 'Get-PCXVideoDuration' {

    BeforeAll {
        . "$PSScriptRoot\..\TestHelper.ps1"
    }

    It 'Returns a TimeSpan' {
        $module = Get-Module PCXLab.VideoTools
        $testVideo = $script:TestVideo
        $Duration = & $module { param($path) Get-PCXVideoDuration -Path $path } $testVideo
        $Duration | Should -BeOfType [TimeSpan]
    }

    It 'Returns a positive duration' {
        $module = Get-Module PCXLab.VideoTools
        $testVideo = $script:TestVideo
        $Duration = & $module { param($path) Get-PCXVideoDuration -Path $path } $testVideo
        $Duration.TotalSeconds | Should -BeGreaterThan 0
    }

}