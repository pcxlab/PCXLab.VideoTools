BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $module = Get-Module PCXLab.VideoTools

    #
    # Create silence events with SourcePath and convert to VideoSegments.
    # The editing pipeline is: Analysis Events -> Get-PCXVideoSegments -> Exporters.
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

    $script:RawSilence = & $module {
        param($TestVideo)

        New-PCXSilenceObject `
            -Start ([TimeSpan]::FromSeconds(10)) `
            -End ([TimeSpan]::FromSeconds(16)) `
            -DurationSeconds 6 `
            -SourcePath $TestVideo
    } $script:TestVideo

    $script:RawBlackFrames = & $module {
        param($TestVideo)

        New-PCXBlackFrameObject `
            -Start ([TimeSpan]::FromSeconds(2)) `
            -End ([TimeSpan]::FromSeconds(5)) `
            -DurationSeconds 3 `
            -SourcePath $TestVideo
    } $script:TestVideo
}

Describe 'Export-PCXPremiereMarkers' {

    It 'Creates a Premiere ExtendScript file from VideoSegments' {
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
        $content | Should -Match 'VideoSegment - Keep'
        $content | Should -Match 'VideoSegment - Remove'
    }

    It 'Applies a requested sequence offset' {
        $outputPath = Join-Path $TestDrive 'OffsetMarkers.jsx'

        $script:EditSegments |
            Export-PCXPremiereMarkers -OutputPath $outputPath -TimeOffsetSeconds 15 | Out-Null

        $content = Get-Content -LiteralPath $outputPath -Raw
        $content | Should -Match '"Start":'
    }

    It 'Exports raw Silence analysis events without applying editing policy' {
        $outputPath = Join-Path $TestDrive 'SilenceMarkers.jsx'

        $script:RawSilence |
            Export-PCXPremiereMarkers -Path $outputPath | Should -Exist

        $content = Get-Content -LiteralPath $outputPath -Raw
        $content | Should -Match 'Silence - EditCandidate'
        $content | Should -Match 'Detected silence: 6 seconds. Classification: EditCandidate.'
    }

    It 'Exports raw BlackFrame analysis events' {
        $outputPath = Join-Path $TestDrive 'BlackFrameMarkers.jsx'

        $script:RawBlackFrames |
            Export-PCXPremiereMarkers -Path $outputPath | Should -Exist

        $content = Get-Content -LiteralPath $outputPath -Raw
        $content | Should -Match 'BlackFrame'
        $content | Should -Match 'Detected black frames: 3 seconds.'
    }

    It 'Exports complete VideoAnalysis container unpacking constituent events' {
        $outputPath = Join-Path $TestDrive 'AnalysisContainerMarkers.jsx'

        $analysis = & (Get-Module PCXLab.VideoTools) {
            param($TestVideo, $sil, $bf)

            New-PCXVideoAnalysisObject `
                -SourcePath $TestVideo `
                -Media ([PSCustomObject]@{ DurationSeconds = 60 }) `
                -Silence @($sil) `
                -BlackFrames @($bf)
        } $script:TestVideo $script:RawSilence $script:RawBlackFrames

        $analysis | Export-PCXPremiereMarkers -Path $outputPath | Should -Exist

        $content = Get-Content -LiteralPath $outputPath -Raw
        $content | Should -Match 'Silence - EditCandidate'
        $content | Should -Match 'BlackFrame'
    }

    It 'Rejects invalid input' {
        $invalid = [PSCustomObject]@{
            InvalidProperty = 'Not an event or segment'
        }

        { $invalid | Export-PCXPremiereMarkers -Path "$TestDrive\Rejected.jsx" } |
            Should -Throw '*InputObject must be a PCXLab.VideoSegment, PCXLab.VideoAnalysis, or valid PCXLab Analysis Event*'
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
