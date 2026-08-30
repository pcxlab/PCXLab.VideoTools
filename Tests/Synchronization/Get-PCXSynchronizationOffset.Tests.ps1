BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $script:Module = Get-Module PCXLab.VideoTools

}

Describe 'Get-PCXSynchronizationOffset' {

    It 'Returns expected output object contract for identical recordings' {

        $result = & $script:Module {
            param($ref, $comp)
            Get-PCXSynchronizationOffset -ReferencePath $ref -ComparisonPath $comp
        } $script:TestVideo $script:TestVideo

        $result | Should -Not -BeNullOrEmpty
        $result.ReferencePath | Should -Be $script:TestVideo
        $result.ComparisonPath | Should -Be $script:TestVideo
        $result.Offset | Should -Be 0.0
        $result.Correlation | Should -Be 1.0
        # Confidence is now computed by Measure-PCXCorrelationConfidence and must be a [0,1] double.
        $result.Confidence | Should -Not -BeNullOrEmpty
        $result.Confidence | Should -BeGreaterOrEqual 0.0
        $result.Confidence | Should -BeLessOrEqual 1.0
        $result.FrameRate | Should -Be 100
        $result.Method | Should -Be 'AudioCorrelation'
        $result.CorrelationResult | Should -Not -BeNullOrEmpty

    }

    It 'Propagates Stage 2A correlation details in CorrelationResult' {

        $result = & $script:Module {
            param($ref, $comp)
            Get-PCXSynchronizationOffset -ReferencePath $ref -ComparisonPath $comp -SearchWindow 5.0 -StepDuration 0.01
        } $script:TestVideo $script:TestVideo

        $corr = $result.CorrelationResult
        $corr | Should -Not -BeNullOrEmpty
        $corr.BestOffset | Should -Be $result.Offset
        $corr.Correlation | Should -Be $result.Correlation
        $corr.SearchWindow | Should -Be 5.0
        $corr.FramesCompared | Should -BeGreaterThan 0
        # Stage 3A fields must be present on the correlation result.
        $corr.PSObject.Properties.Name | Should -Contain 'SecondPeakCorrelation'
        $corr.PSObject.Properties.Name | Should -Contain 'OverlapFraction'
        $corr.OverlapFraction | Should -BeGreaterThan 0.0
        $corr.OverlapFraction | Should -BeLessOrEqual 1.0

    }

    It 'Throws appropriate exception for non-existent reference file' {

        {
            & $script:Module {
                param($comp)
                Get-PCXSynchronizationOffset -ReferencePath 'C:\NonExistentRef.mp4' -ComparisonPath $comp
            } $script:TestVideo
        } | Should -Throw

    }

    It 'Throws appropriate exception for non-existent comparison file' {

        {
            & $script:Module {
                param($ref)
                Get-PCXSynchronizationOffset -ReferencePath $ref -ComparisonPath 'C:\NonExistentComp.mp4'
            } $script:TestVideo
        } | Should -Throw

    }

    It 'Propagates Confidence as a numeric score from Measure-PCXCorrelationConfidence' {

        $result = & $script:Module {
            param($ref, $comp)
            Get-PCXSynchronizationOffset -ReferencePath $ref -ComparisonPath $comp
        } $script:TestVideo $script:TestVideo

        # The orchestrator must populate Confidence via Measure-PCXCorrelationConfidence.
        # Identical recordings produce maximum correlation and overlap, so confidence
        # should be positive and well-defined.
        $result.Confidence | Should -Not -BeNullOrEmpty
        $result.Confidence | Should -BeOfType [double]
        $result.Confidence | Should -BeGreaterThan 0.0
        $result.Confidence | Should -BeLessOrEqual 1.0

        # Confidence in the orchestrator output must match what CorrelationResult implies.
        # (CorrelationResult.Confidence stays $null — confidence lives only in the outer object.)
        $result.CorrelationResult.Confidence | Should -BeNullOrEmpty

    }

    It 'Throws appropriate exception when media file does not contain audio' {

        # Create a temporary dummy file without audio or invalid media
        $tempNoAudio = Join-Path ([System.IO.Path]::GetTempPath()) "NoAudio-$([System.Guid]::NewGuid().ToString('N')).txt"
        'Dummy invalid media content' | Set-Content -Path $tempNoAudio

        try {
            {
                & $script:Module {
                    param($ref, $noAudio)
                    Get-PCXSynchronizationOffset -ReferencePath $ref -ComparisonPath $noAudio
                } $script:TestVideo $tempNoAudio
            } | Should -Throw
        }
        finally {
            if (Test-Path -LiteralPath $tempNoAudio) {
                Remove-Item -LiteralPath $tempNoAudio -Force -ErrorAction SilentlyContinue
            }
        }

    }

}
