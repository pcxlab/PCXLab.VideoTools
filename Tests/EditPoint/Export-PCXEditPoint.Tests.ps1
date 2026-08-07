Describe 'Export-PCXEditPoint' {

    It 'Creates a JSON document' {

        $Path = Join-Path $TestDrive 'EditPoints.json'

        Find-PCXSilence 'C:\Videos\Test.mp4' |
            Get-PCXEditPoint |
            Export-PCXEditPoint `
                -Path $Path

        $Path |
            Should -Exist

    }

    It 'Generates default output path when -Path is omitted' {

        $editPoint = [PSCustomObject]@{
            PSTypeNames = @('PCXLab.EditPoint')
            SourcePath  = Join-Path $TestDrive 'Sample.mp4'
            Start       = [TimeSpan]::Zero
            End         = [TimeSpan]::FromSeconds(5)
        }

        $expectedPath = Join-Path $TestDrive 'Sample-EditPoints.json'
        if (Test-Path $expectedPath) { Remove-Item $expectedPath -Force }

        $result = $editPoint | Export-PCXEditPoint
        $result.FullName | Should -Be $expectedPath
        $expectedPath | Should -Exist

    }

}