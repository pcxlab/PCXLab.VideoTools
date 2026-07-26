BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $script:Streams = Get-PCXMediaStreams $script:TestVideo

}

Describe 'Get-PCXMediaStreams' {

    It 'Returns two streams' {
        $script:Streams.Count | Should -Be 2
    }

    It 'First stream is video' {
        $script:Streams[0].StreamType | Should -Be 'video'
    }

    It 'Second stream is audio' {
        $script:Streams[1].StreamType | Should -Be 'audio'
    }

    It 'Video codec is h264' {
        $script:Streams[0].Codec | Should -Be 'h264'
    }

    It 'Audio codec is aac' {
        $script:Streams[1].Codec | Should -Be 'aac'
    }

}