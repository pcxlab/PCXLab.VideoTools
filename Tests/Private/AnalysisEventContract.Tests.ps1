Describe 'Analysis Event Model Contract' {

    BeforeAll {
        . "$PSScriptRoot\..\TestHelper.ps1"
        $module = Get-Module PCXLab.VideoTools
    }

    Context 'PCXLab.Silence' {

        It 'Exposes the standardized temporal contract and silence-specific properties' {
            $silence = & $module {
                New-PCXSilenceObject `
                    -SourcePath 'C:\Videos\Tutorial.mp4' `
                    -Start ([TimeSpan]::FromSeconds(5)) `
                    -End ([TimeSpan]::FromSeconds(12)) `
                    -DurationSeconds 7
            }

            $silence.PSTypeNames[0] | Should -Be 'PCXLab.Silence'
            $silence.EventType | Should -Be 'Silence'
            $silence.SourcePath | Should -Be 'C:\Videos\Tutorial.mp4'
            $silence.Source | Should -Be 'Tutorial.mp4'
            $silence.Start | Should -Be ([TimeSpan]::FromSeconds(5))
            $silence.End | Should -Be ([TimeSpan]::FromSeconds(12))
            $silence.Duration | Should -Be ([TimeSpan]::FromSeconds(7))
            $silence.StartSeconds | Should -Be 5.0
            $silence.EndSeconds | Should -Be 12.0
            $silence.DurationSeconds | Should -Be 7.0
            $silence.Classification | Should -Be 'EditCandidate'
        }

    }

    Context 'PCXLab.BlackFrame' {

        It 'Exposes the standardized temporal contract' {
            $blackFrame = & $module {
                New-PCXBlackFrameObject `
                    -SourcePath 'C:\Videos\Tutorial.mp4' `
                    -Start ([TimeSpan]::FromSeconds(1.5)) `
                    -End ([TimeSpan]::FromSeconds(3.5)) `
                    -DurationSeconds 2.0
            }

            $blackFrame.PSTypeNames[0] | Should -Be 'PCXLab.BlackFrame'
            $blackFrame.EventType | Should -Be 'BlackFrame'
            $blackFrame.SourcePath | Should -Be 'C:\Videos\Tutorial.mp4'
            $blackFrame.Source | Should -Be 'Tutorial.mp4'
            $blackFrame.Start | Should -Be ([TimeSpan]::FromSeconds(1.5))
            $blackFrame.End | Should -Be ([TimeSpan]::FromSeconds(3.5))
            $blackFrame.Duration | Should -Be ([TimeSpan]::FromSeconds(2.0))
            $blackFrame.StartSeconds | Should -Be 1.5
            $blackFrame.EndSeconds | Should -Be 3.5
            $blackFrame.DurationSeconds | Should -Be 2.0
        }

    }

}
