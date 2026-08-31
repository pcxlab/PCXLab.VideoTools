BeforeAll {
    . "$PSScriptRoot\..\TestHelper.ps1"
    $script:Module = Get-Module PCXLab.VideoTools
}

Describe 'Get-PCXAnalysisPolicy' {

    It 'Returns a PCXLab.AnalysisPolicy object' {
        $policy = & $script:Module {
            Get-PCXAnalysisPolicy
        }

        $policy | Should -Not -BeNullOrEmpty
        $policy.PSTypeNames[0] | Should -Be 'PCXLab.AnalysisPolicy'
    }

    It 'Provides standard Silence analysis policy defaults' {
        $policy = & $script:Module {
            Get-PCXAnalysisPolicy
        }

        $policy.Silence | Should -Not -BeNullOrEmpty
        $policy.Silence.NoiseFloor | Should -Be -35
        $policy.Silence.MinimumDuration | Should -Be 1.0

        $policy.SilenceNoiseFloor | Should -Be -35
        $policy.SilenceMinimumDuration | Should -Be 1.0
    }

    It 'Provides standard BlackFrames analysis policy defaults' {
        $policy = & $script:Module {
            Get-PCXAnalysisPolicy
        }

        $policy.BlackFrames | Should -Not -BeNullOrEmpty
        $policy.BlackFrames.Threshold | Should -Be 0.10
        $policy.BlackFrames.MinimumDuration | Should -Be 0.5

        $policy.BlackFrameThreshold | Should -Be 0.10
        $policy.BlackFrameMinimumDuration | Should -Be 0.5
    }

}
