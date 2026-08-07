Describe 'Import-PCXEditPoint' {

    It 'Imports edit points' {

        $Path = Join-Path $TestDrive 'EditPoints.json'

        Find-PCXSilence 'C:\Videos\Test.mp4' |
            Get-PCXEditPoint |
            Export-PCXEditPoint `
                -Path $Path

        $Imported =
            Import-PCXEditPoint `
                -Path $Path

        $Imported |
            Should -Not -BeNullOrEmpty

        $Imported[0].PSTypeNames |
            Should -Contain 'PCXLab.EditPoint'

    }

}