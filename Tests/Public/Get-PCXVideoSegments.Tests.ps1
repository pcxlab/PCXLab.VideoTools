Describe 'Get-PCXVideoSegments' {

    BeforeAll {
        . "$PSScriptRoot\..\TestHelper.ps1"
        $module = Get-Module PCXLab.VideoTools
    }

    It 'Builds Keep and Remove segments from PCXLab.Silence events' {
        $silence = @(
            Find-PCXSilence -Path $script:TestVideo -MinimumDuration 2 -NoiseFloor -35
        )

        $segments = @($silence | Get-PCXVideoSegments)
        $segments.Count | Should -BeGreaterThan 0
        $segments[0].PSTypeNames[0] | Should -Be 'PCXLab.VideoSegment'
        @($segments | Where-Object Action -eq 'Keep').Count | Should -BeGreaterThan 0
        @($segments | Where-Object Action -eq 'Remove').Count | Should -BeGreaterThan 0
    }

    It 'Builds Keep and Remove segments from PCXLab.BlackFrame events' {
        $blackFrames = @(
            Find-PCXBlackFrames -Path $script:TestVideo
        )

        $segments = @($blackFrames | Get-PCXVideoSegments)
        $segments.Count | Should -BeGreaterThan 0
        $segments[0].PSTypeNames[0] | Should -Be 'PCXLab.VideoSegment'
        @($segments | Where-Object Action -eq 'Keep').Count | Should -BeGreaterThan 0
        @($segments | Where-Object Action -eq 'Remove').Count | Should -BeGreaterThan 0
    }

    It 'Builds Keep and Remove segments from a custom future analysis event' {
        $customEvent = [PSCustomObject]@{
            SourcePath = $script:TestVideo
            Start      = [TimeSpan]::FromSeconds(2)
            End        = [TimeSpan]::FromSeconds(5)
            Duration   = [TimeSpan]::FromSeconds(3)
            EventType  = 'SceneChange'
        }

        $segments = @($customEvent | Get-PCXVideoSegments)
        $segments.Count | Should -BeGreaterThan 1
        $segments[0].Action | Should -Be 'Keep'
        $segments[0].Start | Should -Be ([TimeSpan]::Zero)
        $segments[0].End | Should -Be ([TimeSpan]::FromSeconds(2))

        $segments[1].Action | Should -Be 'Remove'
        $segments[1].Start | Should -Be ([TimeSpan]::FromSeconds(2))
        $segments[1].End | Should -Be ([TimeSpan]::FromSeconds(5))
    }

    It 'Throws a descriptive error when an invalid object is supplied' {
        $invalid = [PSCustomObject]@{
            SomeRandomField = 123
        }

        { $invalid | Get-PCXVideoSegments } | Should -Throw '*contract*'
    }

}
