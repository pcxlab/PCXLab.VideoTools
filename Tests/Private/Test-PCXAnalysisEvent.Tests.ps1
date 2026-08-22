Describe 'Test-PCXAnalysisEvent' {

    BeforeAll {
        . "$PSScriptRoot\..\TestHelper.ps1"
        $module = Get-Module PCXLab.VideoTools
    }

    Context 'Valid Event Contract Objects' {

        It 'Validates a PCXLab.Silence object as true' {
            $silence = & $module {
                New-PCXSilenceObject `
                    -SourcePath 'C:\Videos\Test.mp4' `
                    -Start ([TimeSpan]::FromSeconds(5)) `
                    -End ([TimeSpan]::FromSeconds(10)) `
                    -DurationSeconds 5
            }

            $result = & $module { Test-PCXAnalysisEvent -InputObject $args[0] } $silence
            $result | Should -Be $true
        }

        It 'Validates a PCXLab.BlackFrame object as true' {
            $blackFrame = & $module {
                New-PCXBlackFrameObject `
                    -SourcePath 'C:\Videos\Test.mp4' `
                    -Start ([TimeSpan]::FromSeconds(1)) `
                    -End ([TimeSpan]::FromSeconds(3)) `
                    -DurationSeconds 2
            }

            $result = & $module { Test-PCXAnalysisEvent -InputObject $args[0] } $blackFrame
            $result | Should -Be $true
        }

        It 'Validates a custom analysis event object possessing only required properties' {
            $customEvent = [PSCustomObject]@{
                SourcePath = 'C:\Videos\Test.mp4'
                Start      = [TimeSpan]::FromSeconds(15)
                End        = [TimeSpan]::FromSeconds(20)
                Duration   = [TimeSpan]::FromSeconds(5)
                EventType  = 'SceneChange'
            }

            $result = & $module { Test-PCXAnalysisEvent -InputObject $args[0] } $customEvent
            $result | Should -Be $true
        }

    }

    Context 'Invalid Event Objects' {

        It 'Returns false for null' {
            $result = & $module { Test-PCXAnalysisEvent -InputObject $null }
            $result | Should -Be $false
        }

        It 'Returns false when EventType is missing' {
            $invalid = [PSCustomObject]@{
                SourcePath = 'C:\Videos\Test.mp4'
                Start      = [TimeSpan]::FromSeconds(0)
                End        = [TimeSpan]::FromSeconds(5)
                Duration   = [TimeSpan]::FromSeconds(5)
            }

            $result = & $module { Test-PCXAnalysisEvent -InputObject $args[0] } $invalid
            $result | Should -Be $false
        }

        It 'Returns false when Start or End is not a TimeSpan' {
            $invalid = [PSCustomObject]@{
                SourcePath = 'C:\Videos\Test.mp4'
                Start      = 0.0
                End        = 5.0
                Duration   = 5.0
                EventType  = 'Silence'
            }

            $result = & $module { Test-PCXAnalysisEvent -InputObject $args[0] } $invalid
            $result | Should -Be $false
        }

        It 'Returns false when End is earlier than Start' {
            $invalid = [PSCustomObject]@{
                SourcePath = 'C:\Videos\Test.mp4'
                Start      = [TimeSpan]::FromSeconds(10)
                End        = [TimeSpan]::FromSeconds(5)
                Duration   = [TimeSpan]::FromSeconds(5)
                EventType  = 'Silence'
            }

            $result = & $module { Test-PCXAnalysisEvent -InputObject $args[0] } $invalid
            $result | Should -Be $false
        }

    }

}
