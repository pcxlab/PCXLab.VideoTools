BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $script:Video = Get-PCXVideoInformation $script:SingleSourceVideo

}

Describe 'Get-PCXVideoInformation' {

    It 'Returns the correct PowerShell type' {

        $script:Video.PSTypeNames[0] |
        Should -Be 'PCXLab.VideoInformation'

    }

    It 'Returns the correct file name' {

        $script:Video.FileName |
        Should -Be ([System.IO.Path]::GetFileName($script:SingleSourceVideo))

    }

    It 'Returns the correct width' {

        $script:Video.Width |
        Should -Be 1276

    }

    It 'Returns the correct height' {

        $script:Video.Height |
        Should -Be 720

    }

    It 'Returns the correct resolution' {

        $script:Video.Resolution |
        Should -Be '1276 x 720'

    }

    It 'Returns the correct video codec' {

        $script:Video.VideoCodec |
        Should -Be 'h264'

    }

    It 'Returns the correct audio codec' {

        $script:Video.AudioCodec |
        Should -Be 'aac'

    }

    It 'Returns HasVideo = True' {

        $script:Video.HasVideo |
        Should -BeTrue

    }

    It 'Returns HasAudio = True' {

        $script:Video.HasAudio |
        Should -BeTrue

    }

    It 'Returns one video stream' {

        $script:Video.VideoStreams |
        Should -Be 1

    }

    It 'Returns one audio stream' {

        $script:Video.AudioStreams |
        Should -Be 1

    }

}