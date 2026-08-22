BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $module = Get-Module PCXLab.VideoTools
    $script:Silence1 = & $module {
        param($TestVideo)
        New-PCXSilenceObject -Start ([TimeSpan]::FromSeconds(1)) -End ([TimeSpan]::FromSeconds(4)) -DurationSeconds 3 -SourcePath $TestVideo
    } $script:TestVideo
}

Describe 'Export-PCXSilence' {

    It 'Exports silence analysis objects to a JSON file' {
        $outputPath = Join-Path $TestDrive 'SilenceOutput.json'

        $script:Silence1 |
            Export-PCXSilence -Path $outputPath | Should -Exist

        $content = Get-Content -LiteralPath $outputPath -Raw
        $content | Should -Match 'SchemaVersion'
        $content | Should -Match 'Silence'
    }

    It 'Supports backward compatible -OutputPath alias' {
        $outputPath = Join-Path $TestDrive 'SilenceAliasOutput.json'

        $script:Silence1 |
            Export-PCXSilence -OutputPath $outputPath | Should -Exist
    }

    It 'Generates default output path when -Path is omitted' {
        $silence = [PSCustomObject]@{
            PSTypeName      = 'PCXLab.Silence'
            SourcePath      = Join-Path $TestDrive 'TestMedia.mp4'
            Start           = [TimeSpan]::FromSeconds(1)
            End             = [TimeSpan]::FromSeconds(4)
            DurationSeconds = 3
            Classification  = 'ShortPause'
        }

        $expectedPath = Join-Path $TestDrive 'TestMedia-Silence.json'
        if (Test-Path $expectedPath) { Remove-Item $expectedPath -Force }

        $result = $silence | Export-PCXSilence
        $result.FullName | Should -Be $expectedPath
        $expectedPath | Should -Exist
    }

}
