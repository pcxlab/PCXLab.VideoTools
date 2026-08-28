BeforeAll {
    . "$PSScriptRoot\..\TestHelper.ps1"
    $script:Module = Get-Module PCXLab.VideoTools

    $script:SourcePath = 'C:\Media\Video.mp4'
    $script:AnalysisEvent = [PSCustomObject]@{
        PSTypeName      = 'PCXLab.Silence'
        SourcePath      = $script:SourcePath
        StartSeconds    = 5.0
        EndSeconds      = 6.0
        DurationSeconds = 1.0
        EventType       = 'Silence'
    }

    $script:KeepSegment1 = & $script:Module {
        param($SourcePath, $AnalysisEvents)
        New-PCXVideoSegmentObject `
            -SourcePath $SourcePath `
            -Start ([TimeSpan]::FromSeconds(0)) `
            -End ([TimeSpan]::FromSeconds(10)) `
            -Action 'Keep' `
            -AnalysisEvents $AnalysisEvents
    } $script:SourcePath @($script:AnalysisEvent)

    $script:RemoveSegment = & $script:Module {
        param($SourcePath)
        New-PCXVideoSegmentObject `
            -SourcePath $SourcePath `
            -Start ([TimeSpan]::FromSeconds(10)) `
            -End ([TimeSpan]::FromSeconds(20)) `
            -Action 'Remove'
    } $script:SourcePath

    $script:KeepSegment2 = & $script:Module {
        param($SourcePath)
        New-PCXVideoSegmentObject `
            -SourcePath $SourcePath `
            -Start ([TimeSpan]::FromSeconds(20)) `
            -End ([TimeSpan]::FromSeconds(35)) `
            -Action 'Keep'
    } $script:SourcePath

    $script:VideoSegments = @(
        $script:KeepSegment1
        $script:RemoveSegment
        $script:KeepSegment2
    )

    $script:TimelineMap = [PSCustomObject]@{
        PSTypeName = 'PCXLab.TimelineMap'
        SourcePath = $script:SourcePath
        Intervals  = @(
            [PSCustomObject]@{
                OriginalStartSeconds = 0.0
                OriginalEndSeconds   = 10.0
                EditedStartSeconds   = 0.0
                EditedEndSeconds     = 10.0
            }
            [PSCustomObject]@{
                OriginalStartSeconds = 20.0
                OriginalEndSeconds   = 35.0
                EditedStartSeconds   = 10.0
                EditedEndSeconds     = 25.0
            }
        )
    }
}

Describe 'ConvertTo-PCXEditedSegments' {

    It 'Produces one edited segment for each original Keep segment' {
        $editedSegments = & $script:Module {
            param($VideoSegments, $TimelineMap)
            ConvertTo-PCXEditedSegments `
                -VideoSegments $VideoSegments `
                -TimelineMap $TimelineMap
        } $script:VideoSegments $script:TimelineMap

        @($editedSegments).Count | Should -Be 2
    }

    It 'Excludes Remove segments' {
        $editedSegments = & $script:Module {
            param($VideoSegments, $TimelineMap)
            ConvertTo-PCXEditedSegments `
                -VideoSegments $VideoSegments `
                -TimelineMap $TimelineMap
        } $script:VideoSegments $script:TimelineMap

        @($editedSegments | Where-Object Action -eq 'Remove').Count | Should -Be 0
    }

    It 'Preserves the duration of each Keep segment' {
        $editedSegments = & $script:Module {
            param($VideoSegments, $TimelineMap)
            ConvertTo-PCXEditedSegments `
                -VideoSegments $VideoSegments `
                -TimelineMap $TimelineMap
        } $script:VideoSegments $script:TimelineMap

        $editedSegments[0].DurationSeconds | Should -Be $script:KeepSegment1.DurationSeconds
        $editedSegments[1].DurationSeconds | Should -Be $script:KeepSegment2.DurationSeconds
    }

    It 'Produces a continuous edited timeline' {
        $editedSegments = & $script:Module {
            param($VideoSegments, $TimelineMap)
            ConvertTo-PCXEditedSegments `
                -VideoSegments $VideoSegments `
                -TimelineMap $TimelineMap
        } $script:VideoSegments $script:TimelineMap

        for ($index = 0; $index -lt $editedSegments.Count - 1; $index++) {
            $editedSegments[$index].EndSeconds | Should -Be $editedSegments[$index + 1].StartSeconds
        }
    }

    It 'Preserves Keep segment order' {
        $editedSegments = & $script:Module {
            param($VideoSegments, $TimelineMap)
            ConvertTo-PCXEditedSegments `
                -VideoSegments $VideoSegments `
                -TimelineMap $TimelineMap
        } $script:VideoSegments $script:TimelineMap

        $editedSegments[0].AnalysisEvents.Count | Should -Be 1
        $editedSegments[0].StartSeconds | Should -Be 0.0
        $editedSegments[1].StartSeconds | Should -Be 10.0
    }

    It 'Preserves SourcePath' {
        $editedSegments = & $script:Module {
            param($VideoSegments, $TimelineMap)
            ConvertTo-PCXEditedSegments `
                -VideoSegments $VideoSegments `
                -TimelineMap $TimelineMap
        } $script:VideoSegments $script:TimelineMap

        $editedSegments | ForEach-Object {
            $_.SourcePath | Should -Be $script:SourcePath
        }
    }

    It 'Preserves AnalysisEvents' {
        $editedSegments = & $script:Module {
            param($VideoSegments, $TimelineMap)
            ConvertTo-PCXEditedSegments `
                -VideoSegments $VideoSegments `
                -TimelineMap $TimelineMap
        } $script:VideoSegments $script:TimelineMap

        $editedSegments[0].AnalysisEvents.Count | Should -Be 1
        $editedSegments[0].AnalysisEvents[0].EventType | Should -Be 'Silence'
        $editedSegments[0].AnalysisEvents[0].StartSeconds | Should -Be 5.0
    }

    It 'Throws when a Keep segment has no matching TimelineMap interval' {
        $unmatchedSegment = & $script:Module {
            param($SourcePath)
            New-PCXVideoSegmentObject `
                -SourcePath $SourcePath `
                -Start ([TimeSpan]::FromSeconds(40)) `
                -End ([TimeSpan]::FromSeconds(50)) `
                -Action 'Keep'
        } $script:SourcePath

        {
            & $script:Module {
                param($VideoSegments, $TimelineMap)
                ConvertTo-PCXEditedSegments `
                    -VideoSegments $VideoSegments `
                    -TimelineMap $TimelineMap
            } @($unmatchedSegment) $script:TimelineMap
        } | Should -Throw '*TimelineMap and VideoSegments are inconsistent*'
    }

}
