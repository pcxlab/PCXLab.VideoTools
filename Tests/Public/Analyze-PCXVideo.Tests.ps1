Describe 'Analyze-PCXVideo' {

    BeforeAll {
        . "$PSScriptRoot\..\TestHelper.ps1"
    }

    It 'Analyzes video and produces analysis facts (Media, Silence, BlackFrames, Statistics)' {
        $analysis = Analyze-PCXVideo -Path $script:TestVideo -MinimumDuration 2 -NoiseFloor -35
        $analysis.PSTypeNames[0] | Should -Be 'PCXLab.VideoAnalysis'
        $analysis.Media | Should -Not -BeNullOrEmpty
        $analysis.Analysis.Silence.Count | Should -BeGreaterThan 0
        $analysis.Analysis.BlackFrames | Should -Not -BeNullOrEmpty
        $analysis.Analysis.SilenceStatistics | Should -Not -BeNullOrEmpty
        $null -eq $analysis.Analysis.PSObject.Properties['Segments'] | Should -Be $true
    }

    It 'Analyzes video with no silence matching threshold' {
        # Using extreme silence thresholds so no silence is found
        $analysis = Analyze-PCXVideo -Path $script:TestVideo -MinimumDuration 3600 -NoiseFloor -120
        $analysis.PSTypeNames[0] | Should -Be 'PCXLab.VideoAnalysis'
        $analysis.Analysis.Silence.Count | Should -Be 0
    }

}
