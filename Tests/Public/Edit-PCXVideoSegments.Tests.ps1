Describe 'Edit-PCXVideoSegments Companion Artifact Lifecycle' {

    BeforeAll {
        . "$PSScriptRoot\..\TestHelper.ps1"
        $script:Module = Get-Module PCXLab.VideoTools
    }

    It 'Generates missing companion artifacts even when Edited.mp4 already exists' {
        $tempSource = Join-Path $TestDrive 'TestMedia.mp4'
        $tempEditedVideo = Join-Path $TestDrive 'TestMedia-Edited.mp4'
        $tempEditedCuts = Join-Path $TestDrive 'TestMedia-EditedCuts.jsx'
        $tempEditedMarkers = Join-Path $TestDrive 'TestMedia-EditedMarkers.jsx'

        # Create dummy source and pre-existing edited video
        Set-Content -LiteralPath $tempSource -Value 'source'
        Set-Content -LiteralPath $tempEditedVideo -Value 'pre-existing edited video'

        # Build in-memory segments with analysis events
        $analysisEvent = [PSCustomObject]@{
            SourcePath      = $tempSource
            Start           = [TimeSpan]::FromSeconds(5)
            End             = [TimeSpan]::FromSeconds(10)
            Duration        = [TimeSpan]::FromSeconds(5)
            StartSeconds    = 5.0
            EndSeconds      = 10.0
            DurationSeconds = 5.0
            EventType       = 'Silence'
            Classification  = 'ShortPause'
        }

        $seg1 = & $script:Module {
            param($src)
            New-PCXVideoSegmentObject -SourcePath $src -Start ([TimeSpan]::Zero) -End ([TimeSpan]::FromSeconds(5)) -Action 'Keep'
        } $tempSource

        $seg2 = & $script:Module {
            param($src, $ev)
            New-PCXVideoSegmentObject -SourcePath $src -Start ([TimeSpan]::FromSeconds(5)) -End ([TimeSpan]::FromSeconds(10)) -Action 'Remove' -AnalysisEvents @($ev)
        } $tempSource $analysisEvent

        $seg3 = & $script:Module {
            param($src)
            New-PCXVideoSegmentObject -SourcePath $src -Start ([TimeSpan]::FromSeconds(10)) -End ([TimeSpan]::FromSeconds(20)) -Action 'Keep'
        } $tempSource

        $segments = @($seg1, $seg2, $seg3)

        # Run Edit-PCXVideoSegments without -Force
        # Since TestMedia-Edited.mp4 exists, video encoding is skipped, but companion artifacts must be generated!
        $result = $segments | Edit-PCXVideoSegments

        $result | Should -Not -BeNullOrEmpty
        $result.FullName | Should -Be $tempEditedVideo

        # Both companion artifacts must now exist on disk!
        $tempEditedCuts | Should -Exist
        $tempEditedMarkers | Should -Exist

        # Verify content of EditedCuts
        $cutsContent = Get-Content -LiteralPath $tempEditedCuts -Raw
        $cutsContent | Should -Match '#target premierepro'
        $cutsContent | Should -Match '00:00:05:00' # Seam cut at 5s

        # Verify content of EditedMarkers (Keep markers projected)
        $markersContent = Get-Content -LiteralPath $tempEditedMarkers -Raw
        $markersContent | Should -Match '#target premierepro'
        $markersContent | Should -Match 'Keep'
    }

}
