BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $module = Get-Module PCXLab.VideoTools
    $script:ShortPause = & $module {
        New-PCXSilenceObject -Start ([TimeSpan]::FromSeconds(1.25)) -End ([TimeSpan]::FromSeconds(4.25)) -DurationSeconds 3
    }
    $script:EditCandidate = & $module {
        New-PCXSilenceObject -Start ([TimeSpan]::FromSeconds(10)) -End ([TimeSpan]::FromSeconds(16)) -DurationSeconds 6
    }
    $script:RecordingBreak = & $module {
        New-PCXSilenceObject -Start ([TimeSpan]::FromSeconds(30)) -End ([TimeSpan]::FromSeconds(50)) -DurationSeconds 20
    }
}

Describe 'Export-PCXPremiereMarkers' {

    It 'Creates a Premiere ExtendScript file' {
        $outputPath = Join-Path $TestDrive 'SilenceMarkers.jsx'

        @($script:EditCandidate, $script:RecordingBreak) |
            Export-PCXPremiereMarkers -OutputPath $outputPath | Should -Exist
    }

    It 'Creates range markers with comments and classifications' {
        $outputPath = Join-Path $TestDrive 'MarkerContent.jsx'

        @($script:EditCandidate, $script:RecordingBreak) |
            Export-PCXPremiereMarkers -OutputPath $outputPath | Out-Null

        $content = Get-Content -LiteralPath $outputPath -Raw

        $content | Should -Match '#target premierepro'
        $content | Should -Match 'Silence - EditCandidate'
        $content | Should -Match 'Silence - RecordingBreak'
        $content | Should -Match 'marker\.end = item\.End'
    }

    It 'Excludes short pauses by default' {
        $outputPath = Join-Path $TestDrive 'FilteredMarkers.jsx'

        @($script:ShortPause, $script:EditCandidate) |
            Export-PCXPremiereMarkers -OutputPath $outputPath | Out-Null

        $content = Get-Content -LiteralPath $outputPath -Raw

        $content | Should -Not -Match '"Start":1.25'
        $content | Should -Match '"Start":10'
    }

    It 'Applies a requested sequence offset' {
        $outputPath = Join-Path $TestDrive 'OffsetMarkers.jsx'

        $script:EditCandidate |
            Export-PCXPremiereMarkers -OutputPath $outputPath -TimeOffsetSeconds 15 | Out-Null

        (Get-Content -LiteralPath $outputPath -Raw) | Should -Match '"Start":25'
    }

    It 'Generates default output path when -Path is omitted' {
        $silence = [PSCustomObject]@{
            PSTypeNames    = @('PCXLab.Silence')
            SourcePath     = Join-Path $TestDrive 'Video.mp4'
            Start          = [TimeSpan]::FromSeconds(10)
            End            = [TimeSpan]::FromSeconds(16)
            DurationSeconds= 6
            Classification = 'EditCandidate'
        }

        $expectedPath = Join-Path $TestDrive 'Video-PremiereMarkers.jsx'
        if (Test-Path $expectedPath) { Remove-Item $expectedPath -Force }

        $result = $silence | Export-PCXPremiereMarkers
        $result.FullName | Should -Be $expectedPath
        $expectedPath | Should -Exist
    }
}
