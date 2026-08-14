BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $script:Module = Get-Module PCXLab.VideoTools

    function New-TestMediaSource {
        param(
            [int]$AudioStreamIndex = -1,
            [int]$AudioStreamGlobalIndex = 0
        )

        $audio = [PSCustomObject]@{
            PSTypeName  = 'PCXLab.AudioInformation'
            StreamIndex = $AudioStreamGlobalIndex
        }

        $mediaInfo = [PSCustomObject]@{
            PSTypeName = 'PCXLab.MediaInformation'
            HasAudio   = $true
            Audio      = $audio
        }

        $source = [PSCustomObject]@{
            PSTypeName       = 'PCXLab.MediaSource'
            Path             = 'C:\test.mp4'
            AudioStreamIndex = $AudioStreamIndex
            MediaInformation = $mediaInfo
        }

        $source
    }

}

Describe 'Get-PCXMediaSourceAudioStreamSelector' {

    It 'Returns a:0 when the only audio stream has global index 1' {

        Mock Get-PCXMediaStreams -ModuleName PCXLab.VideoTools -MockWith {
            @(
                [PSCustomObject]@{ Index = 0; StreamType = 'video' },
                [PSCustomObject]@{ Index = 1; StreamType = 'audio' }
            )
        }

        $source = New-TestMediaSource -AudioStreamIndex -1 -AudioStreamGlobalIndex 1

        $selector = & $script:Module {
            param($Source)
            Get-PCXMediaSourceAudioStreamSelector -Source $Source
        } $source

        $selector | Should -Be 'a:0'

    }

    It 'Returns the correct audio-relative selector for multiple audio streams' {

        Mock Get-PCXMediaStreams -ModuleName PCXLab.VideoTools -MockWith {
            @(
                [PSCustomObject]@{ Index = 0; StreamType = 'video' },
                [PSCustomObject]@{ Index = 1; StreamType = 'audio' },
                [PSCustomObject]@{ Index = 2; StreamType = 'audio' }
            )
        }

        $source = New-TestMediaSource -AudioStreamIndex -1 -AudioStreamGlobalIndex 2

        $selector = & $script:Module {
            param($Source)
            Get-PCXMediaSourceAudioStreamSelector -Source $Source
        } $source

        $selector | Should -Be 'a:1'

    }

    It 'Resolves an explicit global audio stream index to the correct audio-relative selector' {

        Mock Get-PCXMediaStreams -ModuleName PCXLab.VideoTools -MockWith {
            @(
                [PSCustomObject]@{ Index = 0; StreamType = 'video' },
                [PSCustomObject]@{ Index = 1; StreamType = 'audio' },
                [PSCustomObject]@{ Index = 2; StreamType = 'audio' }
            )
        }

        $source = New-TestMediaSource -AudioStreamIndex 2 -AudioStreamGlobalIndex 0

        $selector = & $script:Module {
            param($Source)
            Get-PCXMediaSourceAudioStreamSelector -Source $Source
        } $source

        $selector | Should -Be 'a:1'

    }

    It 'Throws when the explicit audio stream index does not exist' {

        Mock Get-PCXMediaStreams -ModuleName PCXLab.VideoTools -MockWith {
            @(
                [PSCustomObject]@{ Index = 0; StreamType = 'video' },
                [PSCustomObject]@{ Index = 1; StreamType = 'audio' }
            )
        }

        $source = New-TestMediaSource -AudioStreamIndex 5 -AudioStreamGlobalIndex 0

        {
            & $script:Module {
                param($Source)
                Get-PCXMediaSourceAudioStreamSelector -Source $Source
            } $source
        } | Should -Throw

    }

}
