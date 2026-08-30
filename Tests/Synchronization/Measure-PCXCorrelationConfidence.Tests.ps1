BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $script:Module = Get-Module PCXLab.VideoTools

    # Helper: build a synthetic CorrelationResult with only the fields
    # that Measure-PCXCorrelationConfidence consumes.
    function New-TestCorrelationResult {
        param(
            [double]$Correlation,
            [double]$OverlapFraction,
            [Nullable[double]]$SecondPeakCorrelation = $null
        )
        return [PSCustomObject]@{
            Correlation           = $Correlation
            OverlapFraction       = $OverlapFraction
            SecondPeakCorrelation = $SecondPeakCorrelation
        }
    }

}

Describe 'Measure-PCXCorrelationConfidence' {

    It 'Returns 1.0 for a perfect result with full overlap and no competing peak' {

        # correlation=1.0, overlapFraction=1.0, no second peak -> no ambiguity discount
        # score = 1.0 * 1.0 = 1.0
        $corr = New-TestCorrelationResult -Correlation 1.0 -OverlapFraction 1.0

        $confidence = & $script:Module {
            param($c)
            Measure-PCXCorrelationConfidence -CorrelationResult $c
        } $corr

        $confidence | Should -Be 1.0

    }

    It 'Applies the overlap fraction as a reliability weight' {

        # correlation=1.0, overlapFraction=0.5, no second peak
        # score = 1.0 * 0.5 = 0.5
        $corr = New-TestCorrelationResult -Correlation 1.0 -OverlapFraction 0.5

        $confidence = & $script:Module {
            param($c)
            Measure-PCXCorrelationConfidence -CorrelationResult $c
        } $corr

        $confidence | Should -Be 0.5

    }

    It 'Applies no ambiguity discount when SecondPeakCorrelation is null' {

        # No second peak found: the ambiguity branch is skipped entirely.
        # score = correlation * overlapFraction = 0.9 * 0.8 = 0.72
        $corr = New-TestCorrelationResult -Correlation 0.9 -OverlapFraction 0.8 -SecondPeakCorrelation $null

        $confidence = & $script:Module {
            param($c)
            Measure-PCXCorrelationConfidence -CorrelationResult $c
        } $corr

        $confidence | Should -Be 0.72

    }

    It 'Reduces confidence proportionally when a strong second peak exists' {

        # correlation=1.0, second=0.5, overlapFraction=1.0
        # prominenceGap = 1.0 - 0.5 = 0.5 -> ambiguityMultiplier = 0.5
        # score = 1.0 * 1.0 * 0.5 = 0.5
        $corr = New-TestCorrelationResult -Correlation 1.0 -OverlapFraction 1.0 -SecondPeakCorrelation 0.5

        $confidence = & $script:Module {
            param($c)
            Measure-PCXCorrelationConfidence -CorrelationResult $c
        } $corr

        $confidence | Should -Be 0.5

    }

    It 'Returns 0.0 when primary and second peak are equal (fully ambiguous)' {

        # correlation=0.9, second=0.9, gap=0 -> ambiguityMultiplier=0 -> score=0
        $corr = New-TestCorrelationResult -Correlation 0.9 -OverlapFraction 1.0 -SecondPeakCorrelation 0.9

        $confidence = & $script:Module {
            param($c)
            Measure-PCXCorrelationConfidence -CorrelationResult $c
        } $corr

        $confidence | Should -Be 0.0

    }

    It 'Returns 0.0 when primary Pearson correlation is negative' {

        # Negative PCC is treated as zero signal quality before any weighting.
        $corr = New-TestCorrelationResult -Correlation -0.3 -OverlapFraction 1.0

        $confidence = & $script:Module {
            param($c)
            Measure-PCXCorrelationConfidence -CorrelationResult $c
        } $corr

        $confidence | Should -Be 0.0

    }

    It 'Clamps score to 0.0 even when second peak is higher than primary' {

        # Pathological case: second >= primary -> gap negative -> multiplier clamped to 0
        $corr = New-TestCorrelationResult -Correlation 0.5 -OverlapFraction 1.0 -SecondPeakCorrelation 0.8

        $confidence = & $script:Module {
            param($c)
            Measure-PCXCorrelationConfidence -CorrelationResult $c
        } $corr

        $confidence | Should -Be 0.0

    }

    It 'Applies ambiguity multiplier of 1.0 when prominence gap >= 1.0' {

        # gap = 1.0 - (-0.5) = 1.5 -> clamped to 1.0 -> no discount
        # score = 0.8 * 0.9 * 1.0 = 0.72
        $corr = New-TestCorrelationResult -Correlation 0.8 -OverlapFraction 0.9 -SecondPeakCorrelation -0.5

        $confidence = & $script:Module {
            param($c)
            Measure-PCXCorrelationConfidence -CorrelationResult $c
        } $corr

        $confidence | Should -Be 0.72

    }

    It 'Combines all three factors correctly' {

        # correlation=0.8, overlapFraction=0.75, second=0.3
        # baseScore        = 0.8
        # weightedScore    = 0.8 * 0.75 = 0.6
        # prominenceGap    = 0.8 - 0.3 = 0.5 -> multiplier = 0.5
        # finalScore       = 0.6 * 0.5 = 0.3
        $corr = New-TestCorrelationResult -Correlation 0.8 -OverlapFraction 0.75 -SecondPeakCorrelation 0.3

        $confidence = & $script:Module {
            param($c)
            Measure-PCXCorrelationConfidence -CorrelationResult $c
        } $corr

        $confidence | Should -Be 0.3

    }

    It 'Returns a value rounded to six decimal places' {

        # correlation=0.7, overlapFraction=0.3, second=0.4
        # baseScore     = 0.7
        # weightedScore = 0.7 * 0.3 = 0.21
        # gap           = 0.7 - 0.4 = 0.3 -> multiplier = 0.3
        # final         = 0.21 * 0.3 = 0.063 (exact in double; 6dp rounds to 0.063)
        $corr = New-TestCorrelationResult -Correlation 0.7 -OverlapFraction 0.3 -SecondPeakCorrelation 0.4

        $confidence = & $script:Module {
            param($c)
            Measure-PCXCorrelationConfidence -CorrelationResult $c
        } $corr

        # Verify the result is a double with exactly 6 dp precision.
        $rounded = [Math]::Round($confidence, 6)
        $confidence | Should -Be $rounded

    }

}
