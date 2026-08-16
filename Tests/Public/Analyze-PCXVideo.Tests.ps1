Describe 'Analyze-PCXVideo' {

    BeforeAll {
        . "$PSScriptRoot\..\TestHelper.ps1"
    }

    It 'Analyzes video containing silence and produces segments' {
        $analysis = Analyze-PCXVideo -Path $script:TestVideo -MinimumDuration 2 -NoiseFloor -35
        $analysis.PSTypeNames[0] | Should -Be 'PCXLab.VideoAnalysis'
        $analysis.Analysis.Silence.Count | Should -BeGreaterThan 0
        $analysis.Analysis.Segments.Count | Should -BeGreaterThan 0
    }

    It 'Analyzes video with no silence and produces a single full-duration Keep segment' {
        # Using extreme silence thresholds so no silence is found
        $analysis = Analyze-PCXVideo -Path $script:TestVideo -MinimumDuration 3600 -NoiseFloor -120
        $analysis.PSTypeNames[0] | Should -Be 'PCXLab.VideoAnalysis'
        $analysis.Analysis.Silence.Count | Should -Be 0
        $analysis.Analysis.Segments.Count | Should -Be 1
        $analysis.Analysis.Segments[0].Action | Should -Be 'Keep'
        $analysis.Analysis.Segments[0].Start | Should -Be ([TimeSpan]::Zero)
        $analysis.Analysis.Segments[0].End | Should -Be $analysis.Media.Duration
    }

}
