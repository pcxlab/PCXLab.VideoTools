BeforeAll {

    . "$PSScriptRoot\..\..\TestHelper.ps1"

    $script:SilenceSample = @(
        '[Parsed_silencedetect_0] silence_start: 1.432125'
        '[Parsed_silencedetect_0] silence_end: 7.220438 | silence_duration: 5.788312'
        '[Parsed_silencedetect_0] silence_start: 53.548458speed=40.6x elapsed=0:00:01.03'
        '[Parsed_silencedetect_0] silence_end: 56.662458 | silence_duration: 3.114'
    )

    $module = Get-Module PCXLab.VideoTools

    $script:ParsedSilences = @(
        & $module {
            param($sample)
            $sample | ConvertTo-PCXSilence
        } $script:SilenceSample
    )
}

Describe 'ConvertTo-PCXSilence' {

    It 'Parses every completed silence pair' {
        $script:ParsedSilences.Count | Should -Be 2
    }

    It 'Parses the first silence boundaries' {
        $script:ParsedSilences[0].StartSeconds | Should -Be 1.432
        $script:ParsedSilences[0].EndSeconds | Should -Be 7.22
        $script:ParsedSilences[0].DurationSeconds | Should -Be 5.788
    }

    It 'Parses silence values when FFmpeg progress text is interleaved' {
        $script:ParsedSilences[1].StartSeconds | Should -Be 53.548
        $script:ParsedSilences[1].EndSeconds | Should -Be 56.662
        $script:ParsedSilences[1].DurationSeconds | Should -Be 3.114
    }

    It 'Classifies the parsed silence region' {
        $script:ParsedSilences[0].Classification | Should -Be 'EditCandidate'
    }
}
