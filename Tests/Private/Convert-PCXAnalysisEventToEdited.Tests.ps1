Describe 'Convert-PCXAnalysisEventToEdited' {

    BeforeAll {
        . "$PSScriptRoot\..\TestHelper.ps1"
        $module = Get-Module PCXLab.VideoTools
    }

    It 'Projects range events onto edited timeline and preserves all properties without type switching' {
        $source = 'C:\Media\Video.mp4'
        $keepSeg1 = & $module { New-PCXVideoSegmentObject -SourcePath 'C:\Media\Video.mp4' -Start ([TimeSpan]::FromSeconds(0)) -End ([TimeSpan]::FromSeconds(2)) -Action 'Keep' }
        $keepSeg2 = & $module { New-PCXVideoSegmentObject -SourcePath 'C:\Media\Video.mp4' -Start ([TimeSpan]::FromSeconds(5)) -End ([TimeSpan]::FromSeconds(8)) -Action 'Keep' }

        $timelineMap = & $module {
            param($Segments)
            New-PCXTimelineMapObject -Segments $Segments
        } @($keepSeg1, $keepSeg2)

        # Custom event spanning 1s to 6s (overlaps keepSeg1 1-2s and keepSeg2 5-6s)
        $customEvent = [PSCustomObject]@{
            PSTypeName      = 'PCXLab.Silence'
            SourcePath      = $source
            Start           = [TimeSpan]::FromSeconds(1)
            End             = [TimeSpan]::FromSeconds(6)
            Duration        = [TimeSpan]::FromSeconds(5)
            StartSeconds    = 1.0
            EndSeconds      = 6.0
            DurationSeconds = 5.0
            EventType       = 'Silence'
            CustomMetadata  = 'TestValue'
        }

        $projected = @(
            & $module {
                param($Event, $Map)
                $Event | Convert-PCXAnalysisEventToEdited -TimelineMap $Map
            } $customEvent $timelineMap
        )

        $projected.Count | Should -Be 2

        # First interval: 1-2s maps to edited 1-2s
        $projected[0].PSTypeNames[0] | Should -Be 'PCXLab.Silence'
        $projected[0].CustomMetadata | Should -Be 'TestValue'
        $projected[0].StartSeconds | Should -Be 1.0
        $projected[0].EndSeconds | Should -Be 2.0
        $projected[0].DurationSeconds | Should -Be 1.0

        # Second interval: 5-6s maps to edited 2-3s
        $projected[1].PSTypeNames[0] | Should -Be 'PCXLab.Silence'
        $projected[1].CustomMetadata | Should -Be 'TestValue'
        $projected[1].StartSeconds | Should -Be 2.0
        $projected[1].EndSeconds | Should -Be 3.0
        $projected[1].DurationSeconds | Should -Be 1.0
    }

    It 'Discards events that fall completely within removed intervals' {
        $source = 'C:\Media\Video.mp4'
        $keepSeg = & $module { New-PCXVideoSegmentObject -SourcePath 'C:\Media\Video.mp4' -Start ([TimeSpan]::FromSeconds(0)) -End ([TimeSpan]::FromSeconds(2)) -Action 'Keep' }

        $timelineMap = & $module {
            param($Segments)
            New-PCXTimelineMapObject -Segments $Segments
        } @($keepSeg)

        # Event in removed interval (3s to 4s)
        $removedEvent = [PSCustomObject]@{
            PSTypeName      = 'PCXLab.WhisperTranscript'
            SourcePath      = $source
            Start           = [TimeSpan]::FromSeconds(3)
            End             = [TimeSpan]::FromSeconds(4)
            Duration        = [TimeSpan]::FromSeconds(1)
            StartSeconds    = 3.0
            EndSeconds      = 4.0
            DurationSeconds = 1.0
            EventType       = 'Whisper'
            Text            = 'Deleted text'
        }

        $projected = @(
            & $module {
                param($Event, $Map)
                $Event | Convert-PCXAnalysisEventToEdited -TimelineMap $Map
            } $removedEvent $timelineMap
        )

        $projected.Count | Should -Be 0
    }

}
