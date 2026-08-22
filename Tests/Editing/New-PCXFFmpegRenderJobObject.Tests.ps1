Describe 'New-PCXFFmpegRenderJobObject' {

    BeforeAll {
        . "$PSScriptRoot\..\TestHelper.ps1"
    }

    It 'Sets PSTypeName to PCXLab.FFmpegRenderJob' {
        $module = Get-Module PCXLab.VideoTools
        $job = & $module { New-PCXFFmpegRenderJobObject -SourcePath 'C:\Video.mp4' -OutputPath 'C:\Out.mp4' -FilterGraph 'test' }
        $job.PSTypeNames | Should -Contain 'PCXLab.FFmpegRenderJob'
    }

    It 'Sets HasAudio to True by default' {
        $module = Get-Module PCXLab.VideoTools
        $job = & $module { New-PCXFFmpegRenderJobObject -SourcePath 'C:\Video.mp4' -OutputPath 'C:\Out.mp4' -FilterGraph 'test' }
        $job.HasAudio | Should -Be $true
        $job.VideoCodec | Should -Be 'libx264'
        $job.AudioCodec | Should -Be 'aac'
    }

    It 'Sets HasAudio to False when specified' {
        $module = Get-Module PCXLab.VideoTools
        $job = & $module { New-PCXFFmpegRenderJobObject -SourcePath 'C:\Video.mp4' -OutputPath 'C:\Out.mp4' -FilterGraph 'test' -HasAudio:$false }
        $job.HasAudio | Should -Be $false
    }

}
