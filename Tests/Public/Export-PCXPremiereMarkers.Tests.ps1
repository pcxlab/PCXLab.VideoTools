BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $module = Get-Module PCXLab.VideoTools

    #
    # Create silence events with SourcePath and convert to VideoSegments.
    # The editing pipeline is now: Analysis Events → Get-PCXVideoSegments → Exporters.
    #

    $script:EditSegments = & $module {
        param($TestVideo)

        $editCandidate = New-PCXSilenceObject `
            -Start ([TimeSpan]::FromSeconds(10)) `
            -End ([TimeSpan]::FromSeconds(16)) `
            -DurationSeconds 6 `
            -SourcePath $TestVideo

        $recordingBreak = New-PCXSilenceObject `
            -Start ([TimeSpan]::FromSeconds(30)) `
            -End ([TimeSpan]::FromSeconds(50)) `
            -DurationSeconds 20 `
            -SourcePath $TestVideo

        @($editCandidate, $recordingBreak) | Get-PCXVideoSegments
    } $script:TestVideo
}

Describe 'Export-PCXPremiereMarkers' {

    It 'Creates a Premiere ExtendScript file' {
        $outputPath = Join-Path $TestDrive 'Markers.jsx'

        $script:EditSegments |
            Export-PCXPremiereMarkers -OutputPath $outputPath | Should -Exist
    }

    It 'Creates range markers with segment actions' {
        $outputPath = Join-Path $TestDrive 'MarkerContent.jsx'

        $script:EditSegments |
            Export-PCXPremiereMarkers -OutputPath $outputPath | Out-Null

        $content = Get-Content -LiteralPath $outputPath -Raw

        $content | Should -Match '#target premierepro'
        $content | Should -Match 'markerData'
        $content | Should -Match 'VideoSegment'
    }

    It 'Applies a requested sequence offset' {
        $outputPath = Join-Path $TestDrive 'OffsetMarkers.jsx'

        $script:EditSegments |
            Export-PCXPremiereMarkers -OutputPath $outputPath -TimeOffsetSeconds 15 | Out-Null

        $content = Get-Content -LiteralPath $outputPath -Raw
        $content | Should -Match '"Start":'
    }

    It 'Rejects non-VideoSegment input' {
        $silence = & (Get-Module PCXLab.VideoTools) {
            param($TestVideo)
            New-PCXSilenceObject `
                -Start ([TimeSpan]::FromSeconds(10)) `
                -End ([TimeSpan]::FromSeconds(16)) `
                -DurationSeconds 6 `
                -SourcePath $TestVideo
        } $script:TestVideo

        { $silence | Export-PCXPremiereMarkers -Path "$TestDrive\Rejected.jsx" } |
            Should -Throw '*PCXLab.VideoSegment*'
    }

    It 'Generates default output path when -Path is omitted' {
        $segment = & (Get-Module PCXLab.VideoTools) {
            param($TestVideo)
            New-PCXVideoSegmentObject `
                -SourcePath $TestVideo `
                -Start ([TimeSpan]::Zero) `
                -End ([TimeSpan]::FromSeconds(5)) `
                -Action 'Keep'
        } $script:TestVideo

        $expectedPath = Join-Path (Split-Path $script:TestVideo -Parent) 'Test-PremiereMarkers.jsx'
        if (Test-Path $expectedPath) { Remove-Item $expectedPath -Force }

        $result = $segment | Export-PCXPremiereMarkers
        $result.FullName | Should -Be $expectedPath
        $expectedPath | Should -Exist

        # Clean up generated file
        Remove-Item $expectedPath -Force -ErrorAction SilentlyContinue
    }
}
