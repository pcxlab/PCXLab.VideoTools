BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $script:Audio = Get-PCXAudioInformation $script:TestVideo

}

Describe 'Get-PCXAudioInformation' {

    It 'Returns the correct PowerShell type' {
        $script:Audio.PSTypeNames[0] | Should -Be 'PCXLab.AudioInformation'
    }

    It 'Returns the correct codec' {
        $script:Audio.AudioCodec | Should -Be 'aac'
    }

    It 'Returns the correct channels' {
        $script:Audio.Channels | Should -Be 1
    }

    It 'Returns the correct sample rate' {
        $script:Audio.SampleRate | Should -Be 48000
    }

    It 'Returns the correct language' {
        $script:Audio.Language | Should -Be 'eng'
    }

    It 'Returns HasAudio = True' {
        $script:Audio.HasAudio | Should -BeTrue
    }

}