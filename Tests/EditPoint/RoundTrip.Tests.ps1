Describe 'EditPoint Round Trip' {

    It 'Exports and imports without losing data' {

        $Path = Join-Path $TestDrive 'EditPoints.json'

        $Original = Find-PCXSilence 'C:\Videos\Test.mp4' |
            Get-PCXEditPoint

        $Original |
            Export-PCXEditPoint -Path $Path

        $Imported = Import-PCXEditPoint -Path $Path

        Compare-Object `
            -ReferenceObject $Original `
            -DifferenceObject $Imported `
            -Property `
                SourcePath,
                StartSeconds,
                EndSeconds,
                DurationSeconds,
                Classification,
                Reason,
                Confidence |
            Should -BeNullOrEmpty

    }

}