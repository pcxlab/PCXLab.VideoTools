BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

}

Describe 'New-PCXMediaSource' {

    It 'Returns a PCXLab.MediaSource object' {

        $source = New-PCXMediaSource -Path $script:TestVideo

        $source.PSTypeNames[0] | Should -Be 'PCXLab.MediaSource'

    }

    It 'Infers the Id from the filename when not supplied' {

        $source = New-PCXMediaSource -Path $script:TestVideo

        $expectedId = [System.IO.Path]::GetFileNameWithoutExtension($script:TestVideo)

        $source.Id | Should -Be $expectedId

    }

    It 'Uses the supplied Id and Label' {

        $source = New-PCXMediaSource `
            -Path $script:TestVideo `
            -Id 'CamA' `
            -Label 'Camera A'

        $source.Id | Should -Be 'CamA'
        $source.Label | Should -Be 'Camera A'

    }

    It 'Infers Primary role for video with audio' {

        $source = New-PCXMediaSource -Path $script:TestVideo -Role Auto

        $source.Role | Should -Be 'Primary'

    }

    It 'Honours an explicit Role override' {

        $source = New-PCXMediaSource `
            -Path $script:TestVideo `
            -Role Audio

        $source.Role | Should -Be 'Audio'

    }

    It 'Populates MediaInformation' {

        $source = New-PCXMediaSource -Path $script:TestVideo

        $source.MediaInformation | Should -Not -BeNullOrEmpty
        $source.MediaInformation.PSTypeNames[0] | Should -Be 'PCXLab.MediaInformation'

    }

    It 'Populates MediaInformation duration' {

        $source = New-PCXMediaSource -Path $script:TestVideo

        $source.MediaInformation.Duration | Should -Not -BeNullOrEmpty
        $source.MediaInformation.Duration.TotalSeconds | Should -BeGreaterThan 0

    }

    It 'Defaults SynchronizationMethod to Auto' {

        $source = New-PCXMediaSource -Path $script:TestVideo

        $source.SynchronizationMethod | Should -Be 'Auto'

    }

    It 'Defaults AnalysisMode to Auto' {

        $source = New-PCXMediaSource -Path $script:TestVideo

        $source.AnalysisMode | Should -Be 'Auto'

    }

    It 'Defaults RenderingMode to Auto' {

        $source = New-PCXMediaSource -Path $script:TestVideo

        $source.RenderingMode | Should -Be 'Auto'

    }

    It 'Honours explicit SynchronizationMethod, AnalysisMode, and RenderingMode' {

        $source = New-PCXMediaSource `
            -Path $script:TestVideo `
            -SynchronizationMethod 'OffsetHint' `
            -AnalysisMode 'Disabled' `
            -RenderingMode 'Enabled'

        $source.SynchronizationMethod | Should -Be 'OffsetHint'
        $source.AnalysisMode | Should -Be 'Disabled'
        $source.RenderingMode | Should -Be 'Enabled'

    }

}
