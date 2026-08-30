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

}
