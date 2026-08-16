BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $script:Module = Get-Module PCXLab.VideoTools

    function New-TestMediaSource {
        param(
            [string]$Role = 'Primary',
            [bool]$HasAudio = $true,
            [bool]$HasVideo = $true,
            [string]$SynchronizationMethod = 'Auto',
            [Nullable[double]]$OffsetHint = $null
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
            OffsetHint            = $OffsetHint
            SynchronizationMethod = $SynchronizationMethod
            AnalysisMode          = 'Auto'
            RenderingMode         = 'Auto'
            MediaInformation      = $mediaInfo
        }

        $source
    }

}

Describe 'Resolve-PCXSourceSynchronizationMethod' {

    It 'Returns explicit SynchronizationMethod unchanged' {

        $source = New-TestMediaSource -SynchronizationMethod 'OffsetHint'

        $result = & $script:Module {
            param($Source)
            Resolve-PCXSourceSynchronizationMethod -Source $Source
        } $source

        $result | Should -Be 'OffsetHint'

    }

    It 'Resolves Auto with audio to AudioCorrelation' {

        $source = New-TestMediaSource -HasAudio $true

        $result = & $script:Module {
            param($Source)
            Resolve-PCXSourceSynchronizationMethod -Source $Source
        } $source

        $result | Should -Be 'AudioCorrelation'

    }

    It 'Resolves Auto without audio but with OffsetHint to OffsetHint' {

        $source = New-TestMediaSource -HasAudio $false -OffsetHint 0

        $result = & $script:Module {
            param($Source)
            Resolve-PCXSourceSynchronizationMethod -Source $Source
        } $source

        $result | Should -Be 'OffsetHint'

    }

    It 'Resolves Auto without audio and without OffsetHint to None' {

        $source = New-TestMediaSource -HasAudio $false

        $result = & $script:Module {
            param($Source)
            Resolve-PCXSourceSynchronizationMethod -Source $Source
        } $source

        $result | Should -Be 'None'

    }

    It 'Prefers audio over OffsetHint when both are present' {

        $source = New-TestMediaSource -HasAudio $true -OffsetHint 5

        $result = & $script:Module {
            param($Source)
            Resolve-PCXSourceSynchronizationMethod -Source $Source
        } $source

        $result | Should -Be 'AudioCorrelation'

    }

}
