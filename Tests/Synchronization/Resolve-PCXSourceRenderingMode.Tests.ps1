BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $script:Module = Get-Module PCXLab.VideoTools

    function New-TestMediaSource {
        param(
            [string]$Role = 'Primary',
            [bool]$HasAudio = $true,
            [bool]$HasVideo = $true,
            [string]$RenderingMode = 'Auto'
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
            AnalysisMode          = 'Auto'
            RenderingMode         = $RenderingMode
            MediaInformation      = $mediaInfo
        }

        $source
    }

}

Describe 'Resolve-PCXSourceRenderingMode' {

    It 'Returns explicit RenderingMode unchanged' {

        $source = New-TestMediaSource -RenderingMode 'Disabled'

        $result = & $script:Module {
            param($Source)
            Resolve-PCXSourceRenderingMode -Source $Source
        } $source

        $result | Should -Be 'Disabled'

    }

    It 'Resolves Auto Primary with video to Enabled' {

        $source = New-TestMediaSource -Role 'Primary' -HasVideo $true

        $result = & $script:Module {
            param($Source)
            Resolve-PCXSourceRenderingMode -Source $Source
        } $source

        $result | Should -Be 'Enabled'

    }

    It 'Resolves Auto Video with video to Enabled' {

        $source = New-TestMediaSource -Role 'Video' -HasAudio $false -HasVideo $true

        $result = & $script:Module {
            param($Source)
            Resolve-PCXSourceRenderingMode -Source $Source
        } $source

        $result | Should -Be 'Enabled'

    }

    It 'Resolves Auto Audio to Disabled' {

        $source = New-TestMediaSource -Role 'Audio' -HasAudio $true -HasVideo $false

        $result = & $script:Module {
            param($Source)
            Resolve-PCXSourceRenderingMode -Source $Source
        } $source

        $result | Should -Be 'Disabled'

    }

    It 'Resolves Auto without video to Disabled' {

        $source = New-TestMediaSource -Role 'Primary' -HasVideo $false

        $result = & $script:Module {
            param($Source)
            Resolve-PCXSourceRenderingMode -Source $Source
        } $source

        $result | Should -Be 'Disabled'

    }

}
