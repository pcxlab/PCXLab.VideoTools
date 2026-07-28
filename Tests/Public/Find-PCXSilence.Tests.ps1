BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $script:Silences = @(Find-PCXSilence -Path $script:TestVideo -MinimumDuration 2 -NoiseFloor -35)
}

Describe 'Find-PCXSilence' {

    It 'Returns one or more silence regions for the test media' {
        $script:Silences.Count | Should -BeGreaterThan 0
    }

    It 'Returns PCXLab.Silence objects' {
        $script:Silences[0].PSTypeNames[0] | Should -Be 'PCXLab.Silence'
    }

    It 'Honours the requested minimum duration' {
        $shortSilences = @($script:Silences | Where-Object DurationSeconds -lt 2)

        $shortSilences.Count | Should -Be 0
    }

    It 'Returns ordered boundaries for every silence region' {
        foreach ($silence in $script:Silences) {
            $silence.EndSeconds | Should -BeGreaterThan $silence.StartSeconds
            $silence.DurationSeconds | Should -BeGreaterThan 0
        }
    }

    It 'Classifies long silence regions as recording breaks' {
        $recordingBreaks = @($script:Silences | Where-Object Classification -eq 'RecordingBreak')

        $recordingBreaks.Count | Should -BeGreaterThan 0
    }
}
