BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $script:Module = Get-Module PCXLab.VideoTools

    function New-TestTimeline {
        param(
            [double[]]$Energies,
            [double]$FrameDuration = 0.01
        )

        $frames = [System.Collections.Generic.List[object]]::new($Energies.Length)
        for ($i = 0; $i -lt $Energies.Length; $i++) {
            $frames.Add([PSCustomObject]@{
                Time   = [Math]::Round($i * $FrameDuration, 6)
                Energy = [double]$Energies[$i]
            })
        }

        return [PSCustomObject]@{
            FrameRate       = [int][Math]::Round(1.0 / $FrameDuration)
            FrameDuration   = $FrameDuration
            AudioSampleRate = 8000
            Frames          = $frames.ToArray()
        }
    }

}

Describe 'Search-PCXAudioCorrelation' {

    It 'Finds zero offset for identical timelines' {

        $energies = @(0.0, 0.1, 0.5, 0.9, 0.3, 0.1, 0.0, 0.2, 0.8, 0.4, 0.0)
        $refTimeline = New-TestTimeline -Energies $energies
        $compTimeline = New-TestTimeline -Energies $energies

        $result = & $script:Module {
            param($ref, $comp)
            Search-PCXAudioCorrelation -ReferenceTimeline $ref -ComparisonTimeline $comp
        } $refTimeline $compTimeline

        $result | Should -Not -BeNullOrEmpty
        $result.BestOffset | Should -Be 0.0
        $result.Correlation | Should -Be 1.0
        $result.Confidence | Should -BeNullOrEmpty
        $result.FramesCompared | Should -Be $energies.Length
        # Identical-length timelines: OverlapFraction = frameCount / min(ref, comp) = 1.0
        $result.OverlapFraction | Should -Be 1.0

    }

    It 'Finds positive offset when comparison timeline is shifted right' {

        $pattern = @(0.0, 0.1, 0.8, 0.9, 0.2, 0.0)
        $refEnergies = @(0.0, 0.0) + $pattern + @(0.0, 0.0, 0.0, 0.0, 0.0)
        $compEnergies = @(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) + $pattern + @(0.0)

        $refTimeline = New-TestTimeline -Energies $refEnergies -FrameDuration 0.01
        $compTimeline = New-TestTimeline -Energies $compEnergies -FrameDuration 0.01

        $result = & $script:Module {
            param($ref, $comp)
            Search-PCXAudioCorrelation -ReferenceTimeline $ref -ComparisonTimeline $comp
        } $refTimeline $compTimeline

        # Pattern starts at index 2 in Ref, index 7 in Comp. Lag = 5 frames -> 0.05s
        $result.BestOffset | Should -Be 0.05
        $result.Correlation | Should -BeGreaterThan 0.95
        # OverlapFraction must be within (0, 1]
        $result.OverlapFraction | Should -BeGreaterThan 0.0
        $result.OverlapFraction | Should -BeLessOrEqual 1.0

    }

    It 'Finds negative offset when comparison timeline is shifted left' {

        $pattern = @(0.0, 0.2, 0.7, 0.9, 0.3, 0.0)
        $refEnergies = @(0.0, 0.0, 0.0, 0.0, 0.0) + $pattern + @(0.0, 0.0)
        $compEnergies = @(0.0) + $pattern + @(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

        $refTimeline = New-TestTimeline -Energies $refEnergies -FrameDuration 0.01
        $compTimeline = New-TestTimeline -Energies $compEnergies -FrameDuration 0.01

        $result = & $script:Module {
            param($ref, $comp)
            Search-PCXAudioCorrelation -ReferenceTimeline $ref -ComparisonTimeline $comp
        } $refTimeline $compTimeline

        # Pattern starts at index 5 in Ref, index 1 in Comp. Lag = -4 frames -> -0.04s
        $result.BestOffset | Should -Be -0.04
        $result.Correlation | Should -BeGreaterThan 0.95
        # OverlapFraction must be within (0, 1]
        $result.OverlapFraction | Should -BeGreaterThan 0.0
        $result.OverlapFraction | Should -BeLessOrEqual 1.0

    }

    It 'Supports timelines of different lengths' {

        $refEnergies = @(0.0, 0.1, 0.4, 0.8, 0.9, 0.3, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        $compEnergies = @(0.0, 0.1, 0.4, 0.8, 0.9, 0.3, 0.1, 0.0)

        $refTimeline = New-TestTimeline -Energies $refEnergies
        $compTimeline = New-TestTimeline -Energies $compEnergies

        $result = & $script:Module {
            param($ref, $comp)
            Search-PCXAudioCorrelation -ReferenceTimeline $ref -ComparisonTimeline $comp
        } $refTimeline $compTimeline

        $result.BestOffset | Should -Be 0.0
        $result.Correlation | Should -Be 1.0
        # OverlapFraction denominator is min(15, 8) = 8; bestOverlap at lag=0 is 8 -> 1.0
        $result.OverlapFraction | Should -Be 1.0

    }

    It 'Handles constant-energy timelines with zero variance without error' {

        $refEnergies = @(0.5, 0.5, 0.5, 0.5, 0.5)
        $compEnergies = @(0.5, 0.5, 0.5, 0.5, 0.5)

        $refTimeline = New-TestTimeline -Energies $refEnergies
        $compTimeline = New-TestTimeline -Energies $compEnergies

        $result = & $script:Module {
            param($ref, $comp)
            Search-PCXAudioCorrelation -ReferenceTimeline $ref -ComparisonTimeline $comp
        } $refTimeline $compTimeline

        $result | Should -Not -BeNullOrEmpty
        $result.Correlation | Should -Be 1.0
        $result.OverlapFraction | Should -Be 1.0

    }

    It 'Evaluates single-frame overlap edge cases' {

        $refEnergies = @(0.8)
        $compEnergies = @(0.8)

        $refTimeline = New-TestTimeline -Energies $refEnergies
        $compTimeline = New-TestTimeline -Energies $compEnergies

        $result = & $script:Module {
            param($ref, $comp)
            Search-PCXAudioCorrelation -ReferenceTimeline $ref -ComparisonTimeline $comp
        } $refTimeline $compTimeline

        $result.BestOffset | Should -Be 0.0
        $result.FramesCompared | Should -Be 1
        # Single-frame timelines: min(1,1) = 1; overlap = 1 -> 1.0
        $result.OverlapFraction | Should -Be 1.0

    }

    It 'Throws when FrameDuration is mismatched between timelines' {

        $refTimeline = New-TestTimeline -Energies @(0.1, 0.5) -FrameDuration 0.01
        $compTimeline = New-TestTimeline -Energies @(0.1, 0.5) -FrameDuration 0.02

        {
            & $script:Module {
                param($ref, $comp)
                Search-PCXAudioCorrelation -ReferenceTimeline $ref -ComparisonTimeline $comp
            } $refTimeline $compTimeline
        } | Should -Throw

    }

    It 'Throws when a timeline has empty frames' {

        $refTimeline = [PSCustomObject]@{ FrameDuration = 0.01; Frames = @() }
        $compTimeline = New-TestTimeline -Energies @(0.1, 0.5)

        {
            & $script:Module {
                param($ref, $comp)
                Search-PCXAudioCorrelation -ReferenceTimeline $ref -ComparisonTimeline $comp
            } $refTimeline $compTimeline
        } | Should -Throw

    }

    It 'Honours StepDuration and SearchWindow parameters' {

        $energies = @(0.0, 0.1, 0.6, 0.9, 0.3, 0.0, 0.0, 0.0)
        $refTimeline = New-TestTimeline -Energies $energies -FrameDuration 0.01
        $compTimeline = New-TestTimeline -Energies $energies -FrameDuration 0.01

        $result = & $script:Module {
            param($ref, $comp)
            Search-PCXAudioCorrelation -ReferenceTimeline $ref -ComparisonTimeline $comp -SearchWindow 0.05 -StepDuration 0.01
        } $refTimeline $compTimeline

        $result.BestOffset | Should -Be 0.0
        $result.SearchWindow | Should -Be 0.05

    }

    It 'Returns SecondPeakCorrelation as null when search range is smaller than the PeakExclusionWindow' {

        # Timelines that are only 10 frames (0.10 s) long at 10 ms frame duration.
        # The full lag range is [-9, 9] which is 0.18 s total — far less than the
        # internal 1-second PeakExclusionWindow.  No lag can be >= 100 frames away
        # from the best lag, so no independent peak can be found.
        $energies = @(0.0, 0.2, 0.6, 0.9, 0.5, 0.2, 0.0, 0.1, 0.3, 0.0)
        $refTimeline = New-TestTimeline -Energies $energies -FrameDuration 0.01
        $compTimeline = New-TestTimeline -Energies $energies -FrameDuration 0.01

        $result = & $script:Module {
            param($ref, $comp)
            Search-PCXAudioCorrelation -ReferenceTimeline $ref -ComparisonTimeline $comp
        } $refTimeline $compTimeline

        $result.SecondPeakCorrelation | Should -BeNullOrEmpty

    }

    It 'Returns SecondPeakCorrelation when a competing independent peak exists' {

        # Use 300-frame (3.0s) sinusoidal timelines so that lag=0 is identical (PCC=1.0)
        # and periodic structure guarantees independent candidate peaks outside the 1.0s (100 frame) exclusion window.
        $ref  = [double[]]::new(300)
        for ($i = 0; $i -lt 300; $i++) {
            $ref[$i] = [Math]::Sin($i * 0.1) + [Math]::Cos($i * 0.05) + 2.0
        }
        $comp = $ref.Clone()

        $refTimeline  = New-TestTimeline -Energies $ref  -FrameDuration 0.01
        $compTimeline = New-TestTimeline -Energies $comp -FrameDuration 0.01

        $result = & $script:Module {
            param($ref, $comp)
            Search-PCXAudioCorrelation -ReferenceTimeline $ref -ComparisonTimeline $comp
        } $refTimeline $compTimeline

        # Primary peak at lag 0 with correlation = 1.0 (identical signals).
        $result.BestOffset  | Should -Be 0.0
        $result.Correlation | Should -Be 1.0

        # A second independent peak must have been found (not $null).
        $result.SecondPeakCorrelation | Should -Not -BeNullOrEmpty

        # The second peak must be strictly less than primary and positive.
        $result.SecondPeakCorrelation | Should -BeLessThan $result.Correlation
        $result.SecondPeakCorrelation | Should -BeGreaterThan 0.0

    }

    It 'Computes OverlapFraction using the shorter timeline as denominator' {

        # ref has 200 frames, comp has 50 frames at 10 ms.
        # At the best alignment (lag = 0) the overlap is min(200, 50) = 50 frames.
        # OverlapFraction = 50 / min(200, 50) = 1.0.
        $refEnergies  = [double[]]::new(200)
        $compEnergies = [double[]]::new(50)

        for ($i = 0; $i -lt 50; $i++) {
            $refEnergies[$i]  = if ($i % 5 -eq 0) { 0.8 } else { 0.1 }
            $compEnergies[$i] = $refEnergies[$i]
        }

        $refTimeline  = New-TestTimeline -Energies $refEnergies  -FrameDuration 0.01
        $compTimeline = New-TestTimeline -Energies $compEnergies -FrameDuration 0.01

        $result = & $script:Module {
            param($ref, $comp)
            Search-PCXAudioCorrelation -ReferenceTimeline $ref -ComparisonTimeline $comp
        } $refTimeline $compTimeline

        $result.OverlapFraction | Should -Be 1.0

    }

}
