BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $script:Module = Get-Module PCXLab.VideoTools

    function New-TestMediaSource {
        param(
            [bool]$HasAudio = $true
        )

        $mediaInfo = [PSCustomObject]@{
            PSTypeName = 'PCXLab.MediaInformation'
            HasAudio   = $HasAudio
            HasVideo   = $true
        }

        $source = [PSCustomObject]@{
            PSTypeName            = 'PCXLab.MediaSource'
            Path                  = 'C:\test.mp4'
            Id                    = 'Test'
            Label                 = 'Test'
            Role                  = 'Primary'
            SourceType            = 'Video'
            AudioStreamIndex      = -1
            OffsetHint            = $null
            SynchronizationMethod = 'Auto'
            AnalysisMode          = 'Auto'
            RenderingMode         = 'Auto'
            MediaInformation      = $mediaInfo
        }

        $source
    }

}

Describe 'Test-PCXSourceAudioSuitableForSynchronization' {

    It 'Returns true when the source has audio' {

        $source = New-TestMediaSource -HasAudio $true

        $result = & $script:Module {
            param($Source)
            Test-PCXSourceAudioSuitableForSynchronization -Source $Source
        } $source

        $result | Should -Be $true

    }

    It 'Returns false when the source has no audio' {

        $source = New-TestMediaSource -HasAudio $false

        $result = & $script:Module {
            param($Source)
            Test-PCXSourceAudioSuitableForSynchronization -Source $Source
        } $source

        $result | Should -Be $false

    }

    It 'Returns false when MediaInformation is missing' {

        $source = New-TestMediaSource -HasAudio $true
        $source.MediaInformation = $null

        $result = & $script:Module {
            param($Source)
            Test-PCXSourceAudioSuitableForSynchronization -Source $Source
        } $source

        $result | Should -Be $false

    }

}
