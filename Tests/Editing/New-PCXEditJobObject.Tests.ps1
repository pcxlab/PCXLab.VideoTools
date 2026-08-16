Describe 'New-PCXEditJobObject' {

    BeforeAll {
        . "$PSScriptRoot\..\TestHelper.ps1"
    }

    It 'Sets HasAudio to True by default' {
        $module = Get-Module PCXLab.VideoTools
        $job = & $module { New-PCXEditJobObject -SourcePath 'C:\Video.mp4' -OutputPath 'C:\Out.mp4' -FilterGraph 'test' }
        $job.HasAudio | Should -Be $true
    }

    It 'Sets HasAudio to False when specified' {
        $module = Get-Module PCXLab.VideoTools
        $job = & $module { New-PCXEditJobObject -SourcePath 'C:\Video.mp4' -OutputPath 'C:\Out.mp4' -FilterGraph 'test' -HasAudio:$false }
        $job.HasAudio | Should -Be $false
    }

}
