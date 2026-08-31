BeforeAll {
    . "$PSScriptRoot\..\TestHelper.ps1"
    $script:Module = Get-Module PCXLab.VideoTools
}

Describe 'Get-PCXEditPolicy' {

    It 'Returns a PCXLab.EditPolicy object' {
        $policy = & $script:Module {
            Get-PCXEditPolicy
        }

        $policy | Should -Not -BeNullOrEmpty
        $policy.PSTypeNames[0] | Should -Be 'PCXLab.EditPolicy'
    }

    It 'Provides standard MinimumSegmentDuration of 250ms' {
        $policy = & $script:Module {
            Get-PCXEditPolicy
        }

        $policy.MinimumSegmentDuration | Should -Be ([TimeSpan]::FromMilliseconds(250))
    }

    It 'Provides standard RecordingBreakThreshold of 15 seconds' {
        $policy = & $script:Module {
            Get-PCXEditPolicy
        }

        $policy.RecordingBreakThreshold | Should -Be ([TimeSpan]::FromSeconds(15))
        $policy.RecordingBreakThreshold.TotalSeconds | Should -Be 15.0
    }

    It 'Provides standard EditCandidateThreshold of 5 seconds' {
        $policy = & $script:Module {
            Get-PCXEditPolicy
        }

        $policy.EditCandidateThreshold | Should -Be ([TimeSpan]::FromSeconds(5))
        $policy.EditCandidateThreshold.TotalSeconds | Should -Be 5.0
    }

}
