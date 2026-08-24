Describe 'Convert-PCXVideoAnalysisToEdited' {

    BeforeAll {
        . "$PSScriptRoot\..\TestHelper.ps1"
        $module = Get-Module PCXLab.VideoTools
    }

    It 'Projects a complete PCXLab.VideoAnalysis container generically' {
        $source = 'C:\Media\Video.mp4'

        $keepSeg1 = & $module { New-PCXVideoSegmentObject -SourcePath 'C:\Media\Video.mp4' -Start ([TimeSpan]::FromSeconds(0)) -End ([TimeSpan]::FromSeconds(2)) -Action 'Keep' }
        $keepSeg2 = & $module { New-PCXVideoSegmentObject -SourcePath 'C:\Media\Video.mp4' -Start ([TimeSpan]::FromSeconds(5)) -End ([TimeSpan]::FromSeconds(8)) -Action 'Keep' }

        $timelineMap = & $module {
            param($Segments)
            New-PCXTimelineMapObject -Segments $Segments
        } @($keepSeg1, $keepSeg2)

        $silenceEvent = [PSCustomObject]@{
            PSTypeName      = 'PCXLab.Silence'
            SourcePath      = $source
            Start           = [TimeSpan]::FromSeconds(1)
            End             = [TimeSpan]::FromSeconds(6)
            Duration        = [TimeSpan]::FromSeconds(5)
            StartSeconds    = 1.0
            EndSeconds      = 6.0
            DurationSeconds = 5.0
            EventType       = 'Silence'
        }

        $blackFrameEvent = [PSCustomObject]@{
            PSTypeName      = 'PCXLab.BlackFrame'
            SourcePath      = $source
            Start           = [TimeSpan]::FromSeconds(0.5)
            End             = [TimeSpan]::FromSeconds(1.5)
            Duration        = [TimeSpan]::FromSeconds(1)
            StartSeconds    = 0.5
            EndSeconds      = 1.5
            DurationSeconds = 1.0
            EventType       = 'BlackFrame'
        }

        $originalAnalysis = & $module {
            param($source, $silence, $blackFrame)
            New-PCXVideoAnalysisObject `
                -SourcePath $source `
                -Media ([PSCustomObject]@{ DurationSeconds = 10 }) `
                -Silence @($silence) `
                -BlackFrames @($blackFrame)
        } $source $silenceEvent $blackFrameEvent

        $editedAnalysis = & $module {
            param($Analysis, $Map)
            $Analysis | Convert-PCXVideoAnalysisToEdited -TimelineMap $Map
        } $originalAnalysis $timelineMap

        $editedAnalysis | Should -Not -BeNullOrEmpty
        $editedAnalysis.PSTypeNames[0] | Should -Be 'PCXLab.VideoAnalysis'
        $editedAnalysis.Media.DurationSeconds | Should -Be $timelineMap.EditedDurationSeconds

        # Silence array projected
        $editedAnalysis.Analysis.Silence.Count | Should -Be 2
        $editedAnalysis.Analysis.Silence[0].PSTypeNames[0] | Should -Be 'PCXLab.Silence'

        # BlackFrame array projected
        $editedAnalysis.Analysis.BlackFrames.Count | Should -Be 1
        $editedAnalysis.Analysis.BlackFrames[0].PSTypeNames[0] | Should -Be 'PCXLab.BlackFrame'
        $editedAnalysis.Analysis.BlackFrames[0].StartSeconds | Should -Be 0.5
        $editedAnalysis.Analysis.BlackFrames[0].EndSeconds | Should -Be 1.5
    }

}
