BeforeAll {
    . "$PSScriptRoot\..\TestHelper.ps1"
    $script:Module = Get-Module PCXLab.VideoTools
}

Describe 'Resolve-PCXSilenceClassification' {

    Context 'Duration in Seconds' {

        It 'Classifies durations >= 15 seconds as RecordingBreak' {
            $class1 = & $script:Module {
                param($d) Resolve-PCXSilenceClassification -DurationSeconds $d
            } 15.0

            $class2 = & $script:Module {
                param($d) Resolve-PCXSilenceClassification -DurationSeconds $d
            } 30.0

            $class1 | Should -Be 'RecordingBreak'
            $class2 | Should -Be 'RecordingBreak'
        }

        It 'Classifies durations >= 5 seconds and < 15 seconds as EditCandidate' {
            $class1 = & $script:Module {
                param($d) Resolve-PCXSilenceClassification -DurationSeconds $d
            } 5.0

            $class2 = & $script:Module {
                param($d) Resolve-PCXSilenceClassification -DurationSeconds $d
            } 10.0

            $class3 = & $script:Module {
                param($d) Resolve-PCXSilenceClassification -DurationSeconds $d
            } 14.99

            $class1 | Should -Be 'EditCandidate'
            $class2 | Should -Be 'EditCandidate'
            $class3 | Should -Be 'EditCandidate'
        }

        It 'Classifies durations < 5 seconds as ShortPause' {
            $class1 = & $script:Module {
                param($d) Resolve-PCXSilenceClassification -DurationSeconds $d
            } 0.5

            $class2 = & $script:Module {
                param($d) Resolve-PCXSilenceClassification -DurationSeconds $d
            } 2.0

            $class3 = & $script:Module {
                param($d) Resolve-PCXSilenceClassification -DurationSeconds $d
            } 4.99

            $class1 | Should -Be 'ShortPause'
            $class2 | Should -Be 'ShortPause'
            $class3 | Should -Be 'ShortPause'
        }

    }

    Context 'Duration as TimeSpan' {

        It 'Accepts TimeSpan objects' {
            $classBreak = & $script:Module {
                param($ts) Resolve-PCXSilenceClassification -Duration $ts
            } ([TimeSpan]::FromSeconds(20))

            $classCandidate = & $script:Module {
                param($ts) Resolve-PCXSilenceClassification -Duration $ts
            } ([TimeSpan]::FromSeconds(7))

            $classPause = & $script:Module {
                param($ts) Resolve-PCXSilenceClassification -Duration $ts
            } ([TimeSpan]::FromSeconds(3))

            $classBreak | Should -Be 'RecordingBreak'
            $classCandidate | Should -Be 'EditCandidate'
            $classPause | Should -Be 'ShortPause'
        }

    }

    Context 'Pipeline Support' {

        It 'Accepts objects from pipeline by property name' {
            $obj = [PSCustomObject]@{
                DurationSeconds = 16.0
            }

            $classification = & $script:Module {
                param($InputObject) $InputObject | Resolve-PCXSilenceClassification
            } $obj

            $classification | Should -Be 'RecordingBreak'
        }

    }

}
