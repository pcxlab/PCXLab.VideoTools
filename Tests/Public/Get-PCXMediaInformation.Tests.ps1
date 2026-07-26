BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $script:Media = Get-PCXMediaInformation $script:TestVideo

}

Describe 'Get-PCXMediaInformation' {

    It 'Returns the correct PowerShell type' {
        $script:Media.PSTypeNames[0] | Should -Be 'PCXLab.MediaInformation'
    }

    It 'Returns the correct resolution' {
        $script:Media.Resolution | Should -Be '1360 x 768'
    }

    It 'Returns the correct video codec' {
        $script:Media.VideoCodec | Should -Be 'h264'
    }

    It 'Returns the correct audio codec' {
        $script:Media.AudioCodec | Should -Be 'aac'
    }

    It 'Contains nested video information' {
        $script:Media.Video | Should -Not -BeNullOrEmpty
    }

    It 'Contains nested audio information' {
        $script:Media.Audio | Should -Not -BeNullOrEmpty
    }

}