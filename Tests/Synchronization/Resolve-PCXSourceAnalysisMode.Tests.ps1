BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $script:Module = Get-Module PCXLab.VideoTools

    function New-TestMediaSource {
        param(
            [string]$Role = 'Primary',
            [bool]$HasAudio = $true,
            [bool]$HasVideo = $true,
            [string]$AnalysisMode = 'Auto'
        )

        $mediaInfo = [PSCustomObject]@{
            PSTypeName = 'PCXLab.MediaInformation'
            HasAudio   = $HasAudio
            HasVideo   = $HasVideo
        }

        $source = [PSCustomObject]@{
            PSTypeName            = 'PCXLab.MediaSource'
            Path                  = 'C:\test.mp4'
            Id                    = 'Test'
            Label                 = 'Test'
            Role                  = $Role
            SourceType            = 'Video'
            AudioStreamIndex      = -1
            OffsetHint            = $null
            SynchronizationMethod = 'Auto'
            AnalysisMode          = $AnalysisMode
            RenderingMode         = 'Auto'
            MediaInformation      = $mediaInfo
        }

        $source
    }

}

Describe 'Resolve-PCXSourceAnalysisMode' {

    It 'Returns explicit AnalysisMode unchanged' {

        $source = New-TestMediaSource -AnalysisMode 'Disabled'

        $result = & $script:Module {
            param($Source)
            Resolve-PCXSourceAnalysisMode -Source $Source
        } $source

        $result | Should -Be 'Disabled'

    }

    It 'Resolves Auto Primary with audio to Enabled' {

        $source = New-TestMediaSource -Role 'Primary' -HasAudio $true

        $result = & $script:Module {
            param($Source)
            Resolve-PCXSourceAnalysisMode -Source $Source
        } $source

        $result | Should -Be 'Enabled'

    }

    It 'Resolves Auto Audio with audio to Enabled' {

        $source = New-TestMediaSource -Role 'Audio' -HasAudio $true -HasVideo $false

        $result = & $script:Module {
            param($Source)
            Resolve-PCXSourceAnalysisMode -Source $Source
        } $source

        $result | Should -Be 'Enabled'

    }

    It 'Resolves Auto without audio to Disabled' {

        $source = New-TestMediaSource -Role 'Primary' -HasAudio $false

        $result = & $script:Module {
            param($Source)
            Resolve-PCXSourceAnalysisMode -Source $Source
        } $source

        $result | Should -Be 'Disabled'

    }

    It 'Resolves Auto Video to Disabled even with audio' {

        $source = New-TestMediaSource -Role 'Video' -HasAudio $true -HasVideo $true

        $result = & $script:Module {
            param($Source)
            Resolve-PCXSourceAnalysisMode -Source $Source
        } $source

        $result | Should -Be 'Disabled'

    }

}
