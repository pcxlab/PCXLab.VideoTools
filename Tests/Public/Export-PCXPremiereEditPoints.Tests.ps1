BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $module = Get-Module PCXLab.VideoTools
    $script:ShortPause = & $module {
        New-PCXSilenceObject -Start ([TimeSpan]::FromSeconds(1)) -End ([TimeSpan]::FromSeconds(4)) -DurationSeconds 3
    }
    $script:EditCandidate = & $module {
        New-PCXSilenceObject -Start ([TimeSpan]::FromSeconds(10)) -End ([TimeSpan]::FromSeconds(16)) -DurationSeconds 6
    }
}

Describe 'Export-PCXPremiereEditPoints' {

    It 'Creates a Premiere edit-point ExtendScript file' {
        $outputPath = Join-Path $TestDrive 'EditPoints.jsx'

        $script:EditCandidate |
            Export-PCXPremiereEditPoints -OutputPath $outputPath | Should -Exist
    }

    It 'Creates unique cuts at every silence boundary' {
        $outputPath = Join-Path $TestDrive 'EditPointContent.jsx'

        $script:EditCandidate |
            Export-PCXPremiereEditPoints -OutputPath $outputPath | Out-Null

        $content = Get-Content -LiteralPath $outputPath -Raw

        $content | Should -Match 'var editPoints = \[10(?:\.0)?,16(?:\.0)?\]'
        $content | Should -Match 'getVideoTrackAt\(videoTrackIndex\)\.razor\(timecode\)'
        $content | Should -Match 'getAudioTrackAt\(audioTrackIndex\)\.razor\(timecode\)'
        $content | Should -Match 'it does not delete or ripple media'
        $content | Should -Match "'PCXLab.VideoTools', true"
    }

    It 'Excludes short pauses by default' {
        $outputPath = Join-Path $TestDrive 'FilteredEditPoints.jsx'

        @($script:ShortPause, $script:EditCandidate) |
            Export-PCXPremiereEditPoints -OutputPath $outputPath | Out-Null

        (Get-Content -LiteralPath $outputPath -Raw) | Should -Match 'var editPoints = \[10(?:\.0)?,16(?:\.0)?\]'
    }

    It 'Can create edit points across all tracks' {
        $outputPath = Join-Path $TestDrive 'AllTrackEditPoints.jsx'

        $script:EditCandidate |
            Export-PCXPremiereEditPoints -OutputPath $outputPath -AllTracks | Out-Null

        (Get-Content -LiteralPath $outputPath -Raw) | Should -Match 'var cutAllTracks = true'
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

        $expectedPath = Join-Path $TestDrive 'Video-PremiereEditPoints.jsx'
        if (Test-Path $expectedPath) { Remove-Item $expectedPath -Force }

        $result = $silence | Export-PCXPremiereEditPoints
        $result.FullName | Should -Be $expectedPath
        $expectedPath | Should -Exist
    }
}
