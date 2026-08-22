Describe 'New-PCXVideoAnalysisObject and Type Restoration' {

    BeforeAll {
        . "$PSScriptRoot\..\TestHelper.ps1"
        $module = Get-Module PCXLab.VideoTools
    }

    It 'Creates a VideoAnalysis object with default empty collections' {
        $analysis = & $module {
            $media = [PSCustomObject]@{ Duration = [TimeSpan]::FromMinutes(5) }
            New-PCXVideoAnalysisObject -SourcePath 'C:\Videos\Test.mp4' -Media $media
        }

        $analysis.PSTypeNames[0] | Should -Be 'PCXLab.VideoAnalysis'
        $analysis.SourcePath | Should -Be 'C:\Videos\Test.mp4'
        $analysis.Analysis.Silence | Should -BeNullOrEmpty
        $analysis.Analysis.BlackFrames | Should -BeNullOrEmpty
        $analysis.Analysis.Segments | Should -BeNullOrEmpty
        $null -eq $analysis.Analysis.SilenceStatistics | Should -Be $true
    }

    It 'Creates a VideoAnalysis object with BlackFrames and Silence' {
        $analysis = & $module {
            $media = [PSCustomObject]@{ Duration = [TimeSpan]::FromMinutes(5) }
            $silence = @(
                New-PCXSilenceObject -SourcePath 'C:\Videos\Test.mp4' -Start ([TimeSpan]::FromSeconds(10)) -End ([TimeSpan]::FromSeconds(15)) -DurationSeconds 5
            )
            $blackFrames = @(
                New-PCXBlackFrameObject -SourcePath 'C:\Videos\Test.mp4' -Start ([TimeSpan]::FromSeconds(20)) -End ([TimeSpan]::FromSeconds(22)) -DurationSeconds 2
            )
            $segments = @(
                New-PCXVideoSegmentObject -SourcePath 'C:\Videos\Test.mp4' -Start ([TimeSpan]::Zero) -End ([TimeSpan]::FromSeconds(10)) -Action 'Keep'
            )

            New-PCXVideoAnalysisObject `
                -SourcePath 'C:\Videos\Test.mp4' `
                -Media $media `
                -Silence $silence `
                -BlackFrames $blackFrames `
                -Segments $segments
        }

        $analysis.Analysis.Silence.Count | Should -Be 1
        $analysis.Analysis.BlackFrames.Count | Should -Be 1
        $analysis.Analysis.Segments.Count | Should -Be 1
        $analysis.Analysis.BlackFrames[0].PSTypeNames[0] | Should -Be 'PCXLab.BlackFrame'
    }

    It 'Restores BlackFrames and TimeSpan properties from JSON deserialization' {
        $tempJson = [System.IO.Path]::GetTempFileName()
        try {
            $analysis = & $module {
                $media = [PSCustomObject]@{ Duration = [TimeSpan]::FromMinutes(5) }
                $blackFrames = @(
                    New-PCXBlackFrameObject -SourcePath 'C:\Videos\Test.mp4' -Start ([TimeSpan]::FromSeconds(20.5)) -End ([TimeSpan]::FromSeconds(22.5)) -DurationSeconds 2.0
                )
                New-PCXVideoAnalysisObject -SourcePath 'C:\Videos\Test.mp4' -Media $media -BlackFrames $blackFrames
            }

            $null = $analysis | Export-PCXVideoAnalysis -Path $tempJson -Force
            $imported = Import-PCXVideoAnalysis -Path $tempJson

            $imported.PSTypeNames[0] | Should -Be 'PCXLab.VideoAnalysis'
            $imported.Analysis.BlackFrames.Count | Should -Be 1
            $imported.Analysis.BlackFrames[0].PSTypeNames[0] | Should -Be 'PCXLab.BlackFrame'
            $imported.Analysis.BlackFrames[0].Start | Should -BeOfType [TimeSpan]
            $imported.Analysis.BlackFrames[0].Start.TotalSeconds | Should -Be 20.5
            $imported.Analysis.BlackFrames[0].End | Should -BeOfType [TimeSpan]
            $imported.Analysis.BlackFrames[0].End.TotalSeconds | Should -Be 22.5
            $imported.Analysis.BlackFrames[0].Duration | Should -BeOfType [TimeSpan]
            $imported.Analysis.BlackFrames[0].Duration.TotalSeconds | Should -Be 2.0
        }
        finally {
            if (Test-Path -LiteralPath $tempJson) {
                Remove-Item -LiteralPath $tempJson -Force
            }
        }
    }

}
