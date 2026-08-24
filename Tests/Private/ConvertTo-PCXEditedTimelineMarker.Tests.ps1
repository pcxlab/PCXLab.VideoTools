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

    function script:New-TestMarker($start, $end, $name, $kind = 'Analysis', $subKind = 'Silence', $colorIndex = $null) {
        & $script:Module {
            param($s, $e, $n, $k, $sub, $ci)
            New-PCXPremiereMarkerObject `
                -StartSeconds $s `
                -EndSeconds $e `
                -Name $n `
                -MarkerKind $k `
                -MarkerSubKind $sub `
                -ColorIndex $ci
        } $start $end $name $kind $subKind $colorIndex
    }
}

Describe 'ConvertTo-PCXEditedTimelineMarker' {

    BeforeAll {
        # Original: Keep 0-10 -> Edited: 0-10
        # Original: Remove 10-20 -> Removed
        # Original: Keep 20-40 -> Edited: 10-30
        $script:Segments = @(
            script:New-TestSegment 0 10 'Keep'
            script:New-TestSegment 10 20 'Remove'
            script:New-TestSegment 20 40 'Keep'
        )
        $script:TimelineMap = & $script:Module {
            param($segs)
            New-PCXTimelineMapObject -Segments $segs
        } $script:Segments
    }

    It 'Projects marker falling entirely within first kept interval' {
        $marker = script:New-TestMarker 2.0 5.0 'Silence' 'Analysis' 'Silence'
        $edited = & $script:Module {
            param($m, $tm)
            ConvertTo-PCXEditedTimelineMarker -Marker $m -TimelineMap $tm
        } $marker $script:TimelineMap

        $edited | Should -Not -BeNullOrEmpty
        $edited.StartSeconds | Should -Be 2.0
        $edited.EndSeconds | Should -Be 5.0
        $edited.DurationSeconds | Should -Be 3.0
        $edited.MarkerKind | Should -Be 'Analysis'
        $edited.MarkerSubKind | Should -Be 'Silence'
        $edited.Name | Should -Be 'Silence'
    }

    It 'Projects and shifts marker falling within second kept interval' {
        # Original 25.0 - 30.0 -> shifted by 10s of removed content -> Edited: 15.0 - 20.0
        $marker = script:New-TestMarker 25.0 30.0 'Speech' 'Analysis' 'Speech' 7
        $edited = & $script:Module {
            param($m, $tm)
            ConvertTo-PCXEditedTimelineMarker -Marker $m -TimelineMap $tm
        } $marker $script:TimelineMap

        $edited | Should -Not -BeNullOrEmpty
        $edited.StartSeconds | Should -Be 15.0
        $edited.EndSeconds | Should -Be 20.0
        $edited.DurationSeconds | Should -Be 5.0
        $edited.MarkerKind | Should -Be 'Analysis'
        $edited.MarkerSubKind | Should -Be 'Speech'
        $edited.ColorIndex | Should -Be 7
    }

    It 'Discards marker falling entirely within removed interval' {
        # Original 12.0 - 18.0 is inside Remove 10-20
        $marker = script:New-TestMarker 12.0 18.0 'Silence' 'Analysis' 'Silence'
        $edited = & $script:Module {
            param($m, $tm)
            ConvertTo-PCXEditedTimelineMarker -Marker $m -TimelineMap $tm
        } $marker $script:TimelineMap

        $edited | Should -BeNullOrEmpty
    }

    It 'Clamps marker overlapping boundary between Remove and Keep' {
        # Original 15.0 - 25.0 spans Remove (15-20) and Keep (20-25)
        # Overlap with Keep is 20.0 - 25.0 -> Edited: 10.0 - 15.0
        $marker = script:New-TestMarker 15.0 25.0 'Black Frame' 'Analysis' 'BlackFrame'
        $edited = & $script:Module {
            param($m, $tm)
            ConvertTo-PCXEditedTimelineMarker -Marker $m -TimelineMap $tm
        } $marker $script:TimelineMap

        $edited | Should -Not -BeNullOrEmpty
        $edited.StartSeconds | Should -Be 10.0
        $edited.EndSeconds | Should -Be 15.0
        $edited.DurationSeconds | Should -Be 5.0
    }

    It 'Projects point marker accurately' {
        # Point marker at original 22.0 -> Edited: 12.0
        $marker = script:New-TestMarker 22.0 22.0 'Chapter' 'Analysis' 'Chapter'
        $edited = & $script:Module {
            param($m, $tm)
            ConvertTo-PCXEditedTimelineMarker -Marker $m -TimelineMap $tm
        } $marker $script:TimelineMap

        $edited | Should -Not -BeNullOrEmpty
        $edited.StartSeconds | Should -Be 12.0
        $edited.EndSeconds | Should -Be 12.0
    }

}

Describe 'Get-PCXEditedCutPoints' {

    It 'Extracts seam cut points from a timeline map' {
        $segments = @(
            script:New-TestSegment 0 10 'Keep'
            script:New-TestSegment 10 20 'Remove'
            script:New-TestSegment 20 35 'Keep'
            script:New-TestSegment 35 40 'Remove'
            script:New-TestSegment 40 60 'Keep'
        )

        $cuts = & $script:Module {
            param($segs)
            Get-PCXEditedCutPoints -Segments $segs
        } $segments

        $cuts.Count | Should -Be 2
        $cuts[0] | Should -Be 10.0
        $cuts[1] | Should -Be 25.0
    }

}
