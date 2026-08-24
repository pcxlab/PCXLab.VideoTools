BeforeAll {
    . "$PSScriptRoot\..\TestHelper.ps1"
    $script:Module = Get-Module PCXLab.VideoTools

    function script:New-TestSegment($start, $end, $action) {
        & $script:Module {
            param($s, $e, $a)
            New-PCXVideoSegmentObject `
                -SourcePath 'C:\Media\Video.mp4' `
                -Start ([TimeSpan]::FromSeconds($s)) `
                -End ([TimeSpan]::FromSeconds($e)) `
                -Action $a
        } $start $end $action
    }
}

Describe 'New-PCXTimelineMapObject' {

    It 'Builds timeline map with accurate intervals and seam cuts for multiple segments' {
        # Original timeline:
        # Keep 0-10 (10s) -> Edited: 0-10
        # Remove 10-20 (10s) -> removed
        # Keep 20-35 (15s) -> Edited: 10-25
        # Remove 35-40 (5s) -> removed
        # Keep 40-60 (20s) -> Edited: 25-45
        $segments = @(
            script:New-TestSegment 0 10 'Keep'
            script:New-TestSegment 10 20 'Remove'
            script:New-TestSegment 20 35 'Keep'
            script:New-TestSegment 35 40 'Remove'
            script:New-TestSegment 40 60 'Keep'
        )

        $map = & $script:Module {
            param($segs)
            New-PCXTimelineMapObject -Segments $segs
        } $segments

        $map | Should -Not -BeNullOrEmpty
        $map.PSTypeNames | Should -Contain 'PCXLab.TimelineMap'
        $map.SourcePath | Should -Be 'C:\Media\Video.mp4'
        $map.OriginalDurationSeconds | Should -Be 60.0
        $map.EditedDurationSeconds | Should -Be 45.0
        $map.TotalRemovedSeconds | Should -Be 15.0

        # Intervals
        $map.Intervals.Count | Should -Be 3
        $map.Intervals[0].OriginalStartSeconds | Should -Be 0.0
        $map.Intervals[0].OriginalEndSeconds | Should -Be 10.0
        $map.Intervals[0].EditedStartSeconds | Should -Be 0.0
        $map.Intervals[0].EditedEndSeconds | Should -Be 10.0
        $map.Intervals[0].DurationSeconds | Should -Be 10.0

        $map.Intervals[1].OriginalStartSeconds | Should -Be 20.0
        $map.Intervals[1].OriginalEndSeconds | Should -Be 35.0
        $map.Intervals[1].EditedStartSeconds | Should -Be 10.0
        $map.Intervals[1].EditedEndSeconds | Should -Be 25.0
        $map.Intervals[1].DurationSeconds | Should -Be 15.0

        $map.Intervals[2].OriginalStartSeconds | Should -Be 40.0
        $map.Intervals[2].OriginalEndSeconds | Should -Be 60.0
        $map.Intervals[2].EditedStartSeconds | Should -Be 25.0
        $map.Intervals[2].EditedEndSeconds | Should -Be 45.0
        $map.Intervals[2].DurationSeconds | Should -Be 20.0

        # Seam cuts between adjacent kept clips (at edited 10.0 and 25.0)
        $map.EditedCutPointsSeconds.Count | Should -Be 2
        $map.EditedCutPointsSeconds[0] | Should -Be 10.0
        $map.EditedCutPointsSeconds[1] | Should -Be 25.0
    }

    It 'Yields zero seam cuts when there is only one kept segment' {
        $segments = @(
            script:New-TestSegment 0 30 'Keep'
            script:New-TestSegment 30 50 'Remove'
        )

        $map = & $script:Module {
            param($segs)
            New-PCXTimelineMapObject -Segments $segs
        } $segments

        $map.EditedCutPointsSeconds.Count | Should -Be 0
        $map.EditedDurationSeconds | Should -Be 30.0
        $map.TotalRemovedSeconds | Should -Be 20.0
    }

    It 'Throws when no Keep segments are found' {
        $segments = @(
            script:New-TestSegment 0 30 'Remove'
        )

        {
            & $script:Module {
                param($segs)
                New-PCXTimelineMapObject -Segments $segs
            } $segments
        } | Should -Throw '*No Keep segments were found*'
    }

    It 'Throws when segments from different sources are mixed' {
        $seg1 = & $script:Module {
            New-PCXVideoSegmentObject -SourcePath 'C:\Media\VideoA.mp4' -Start ([TimeSpan]::Zero) -End ([TimeSpan]::FromSeconds(5)) -Action 'Keep'
        }
        $seg2 = & $script:Module {
            New-PCXVideoSegmentObject -SourcePath 'C:\Media\VideoB.mp4' -Start ([TimeSpan]::Zero) -End ([TimeSpan]::FromSeconds(5)) -Action 'Keep'
        }

        {
            & $script:Module {
                param($s1, $s2)
                New-PCXTimelineMapObject -Segments @($s1, $s2)
            } $seg1 $seg2
        } | Should -Throw '*All video segments must belong to the same source*'
    }

}
