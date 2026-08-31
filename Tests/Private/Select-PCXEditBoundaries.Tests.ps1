BeforeAll {
    . "$PSScriptRoot\..\TestHelper.ps1"
    $script:Module = Get-Module PCXLab.VideoTools
    $script:SourcePath = 'C:\Media\TestVideo.mp4'
}

Describe 'Select-PCXEditBoundaries' {

    It 'Builds Keep and Remove segments for an event in the middle of the timeline' {
        $event = [PSCustomObject]@{
            SourcePath      = $script:SourcePath
            Start           = [TimeSpan]::FromSeconds(2)
            End             = [TimeSpan]::FromSeconds(5)
            Duration        = [TimeSpan]::FromSeconds(3)
            StartSeconds    = 2.0
            EndSeconds      = 5.0
            DurationSeconds = 3.0
            EventType       = 'Silence'
        }

        $segments = & $script:Module {
            param($Events, $SourcePath, $Duration)
            Select-PCXEditBoundaries `
                -Events $Events `
                -SourcePath $SourcePath `
                -Duration $Duration
        } @($event) $script:SourcePath ([TimeSpan]::FromSeconds(10))

        @($segments).Count | Should -Be 3

        $segments[0].Action | Should -Be 'Keep'
        $segments[0].StartSeconds | Should -Be 0.0
        $segments[0].EndSeconds | Should -Be 2.0
        $segments[0].SourcePath | Should -Be $script:SourcePath

        $segments[1].Action | Should -Be 'Remove'
        $segments[1].StartSeconds | Should -Be 2.0
        $segments[1].EndSeconds | Should -Be 5.0
        $segments[1].SourcePath | Should -Be $script:SourcePath
        $segments[1].AnalysisEvents.Count | Should -Be 1
        $segments[1].AnalysisEvents[0] | Should -Be $event

        $segments[2].Action | Should -Be 'Keep'
        $segments[2].StartSeconds | Should -Be 5.0
        $segments[2].EndSeconds | Should -Be 10.0
        $segments[2].SourcePath | Should -Be $script:SourcePath
    }

    It 'Builds segments when an event starts at the beginning of the timeline' {
        $event = [PSCustomObject]@{
            SourcePath      = $script:SourcePath
            Start           = [TimeSpan]::Zero
            End             = [TimeSpan]::FromSeconds(3)
            Duration        = [TimeSpan]::FromSeconds(3)
            StartSeconds    = 0.0
            EndSeconds      = 3.0
            DurationSeconds = 3.0
            EventType       = 'Silence'
        }

        $segments = & $script:Module {
            param($Events, $SourcePath, $Duration)
            Select-PCXEditBoundaries `
                -Events $Events `
                -SourcePath $SourcePath `
                -Duration $Duration
        } @($event) $script:SourcePath ([TimeSpan]::FromSeconds(10))

        @($segments).Count | Should -Be 2

        $segments[0].Action | Should -Be 'Remove'
        $segments[0].StartSeconds | Should -Be 0.0
        $segments[0].EndSeconds | Should -Be 3.0

        $segments[1].Action | Should -Be 'Keep'
        $segments[1].StartSeconds | Should -Be 3.0
        $segments[1].EndSeconds | Should -Be 10.0
    }

    It 'Builds segments when an event ends at the end of the timeline' {
        $event = [PSCustomObject]@{
            SourcePath      = $script:SourcePath
            Start           = [TimeSpan]::FromSeconds(7)
            End             = [TimeSpan]::FromSeconds(10)
            Duration        = [TimeSpan]::FromSeconds(3)
            StartSeconds    = 7.0
            EndSeconds      = 10.0
            DurationSeconds = 3.0
            EventType       = 'Silence'
        }

        $segments = & $script:Module {
            param($Events, $SourcePath, $Duration)
            Select-PCXEditBoundaries `
                -Events $Events `
                -SourcePath $SourcePath `
                -Duration $Duration
        } @($event) $script:SourcePath ([TimeSpan]::FromSeconds(10))

        @($segments).Count | Should -Be 2

        $segments[0].Action | Should -Be 'Keep'
        $segments[0].StartSeconds | Should -Be 0.0
        $segments[0].EndSeconds | Should -Be 7.0

        $segments[1].Action | Should -Be 'Remove'
        $segments[1].StartSeconds | Should -Be 7.0
        $segments[1].EndSeconds | Should -Be 10.0
    }

    It 'Correctly orders unordered analysis events' {
        $event1 = [PSCustomObject]@{
            SourcePath      = $script:SourcePath
            Start           = [TimeSpan]::FromSeconds(6)
            End             = [TimeSpan]::FromSeconds(8)
            Duration        = [TimeSpan]::FromSeconds(2)
            StartSeconds    = 6.0
            EndSeconds      = 8.0
            DurationSeconds = 2.0
            EventType       = 'Silence'
        }

        $event2 = [PSCustomObject]@{
            SourcePath      = $script:SourcePath
            Start           = [TimeSpan]::FromSeconds(2)
            End             = [TimeSpan]::FromSeconds(4)
            Duration        = [TimeSpan]::FromSeconds(2)
            StartSeconds    = 2.0
            EndSeconds      = 4.0
            DurationSeconds = 2.0
            EventType       = 'BlackFrame'
        }

        $segments = & $script:Module {
            param($Events, $SourcePath, $Duration)
            Select-PCXEditBoundaries `
                -Events $Events `
                -SourcePath $SourcePath `
                -Duration $Duration
        } @($event1, $event2) $script:SourcePath ([TimeSpan]::FromSeconds(10))

        @($segments).Count | Should -Be 5

        $segments[0].Action | Should -Be 'Keep'
        $segments[0].StartSeconds | Should -Be 0.0
        $segments[0].EndSeconds | Should -Be 2.0

        $segments[1].Action | Should -Be 'Remove'
        $segments[1].StartSeconds | Should -Be 2.0
        $segments[1].EndSeconds | Should -Be 4.0
        $segments[1].AnalysisEvents[0].EventType | Should -Be 'BlackFrame'

        $segments[2].Action | Should -Be 'Keep'
        $segments[2].StartSeconds | Should -Be 4.0
        $segments[2].EndSeconds | Should -Be 6.0

        $segments[3].Action | Should -Be 'Remove'
        $segments[3].StartSeconds | Should -Be 6.0
        $segments[3].EndSeconds | Should -Be 8.0
        $segments[3].AnalysisEvents[0].EventType | Should -Be 'Silence'

        $segments[4].Action | Should -Be 'Keep'
        $segments[4].StartSeconds | Should -Be 8.0
        $segments[4].EndSeconds | Should -Be 10.0
    }

    It 'Accepts analysis events from pipeline input' {
        $event1 = [PSCustomObject]@{
            SourcePath      = $script:SourcePath
            Start           = [TimeSpan]::FromSeconds(2)
            End             = [TimeSpan]::FromSeconds(4)
            Duration        = [TimeSpan]::FromSeconds(2)
            StartSeconds    = 2.0
            EndSeconds      = 4.0
            DurationSeconds = 2.0
            EventType       = 'Silence'
        }

        $event2 = [PSCustomObject]@{
            SourcePath      = $script:SourcePath
            Start           = [TimeSpan]::FromSeconds(6)
            End             = [TimeSpan]::FromSeconds(8)
            Duration        = [TimeSpan]::FromSeconds(2)
            StartSeconds    = 6.0
            EndSeconds      = 8.0
            DurationSeconds = 2.0
            EventType       = 'Silence'
        }

        $segments = & $script:Module {
            param($Events, $SourcePath, $Duration)
            $Events | Select-PCXEditBoundaries `
                -SourcePath $SourcePath `
                -Duration $Duration
        } @($event1, $event2) $script:SourcePath ([TimeSpan]::FromSeconds(10))

        @($segments).Count | Should -Be 5
        $segments[1].Action | Should -Be 'Remove'
        $segments[3].Action | Should -Be 'Remove'
    }

    It 'Generates a single Keep segment when no events are provided' {
        $segments = & $script:Module {
            param($SourcePath, $Duration)
            Select-PCXEditBoundaries `
                -Events @() `
                -SourcePath $SourcePath `
                -Duration $Duration
        } $script:SourcePath ([TimeSpan]::FromSeconds(10))

        @($segments).Count | Should -Be 1
        $segments[0].Action | Should -Be 'Keep'
        $segments[0].StartSeconds | Should -Be 0.0
        $segments[0].EndSeconds | Should -Be 10.0
    }

    It 'Generates a single Remove segment when an event covers the entire timeline' {
        $event = [PSCustomObject]@{
            SourcePath      = $script:SourcePath
            Start           = [TimeSpan]::Zero
            End             = [TimeSpan]::FromSeconds(10)
            Duration        = [TimeSpan]::FromSeconds(10)
            StartSeconds    = 0.0
            EndSeconds      = 10.0
            DurationSeconds = 10.0
            EventType       = 'Silence'
        }

        $segments = & $script:Module {
            param($Events, $SourcePath, $Duration)
            Select-PCXEditBoundaries `
                -Events $Events `
                -SourcePath $SourcePath `
                -Duration $Duration
        } @($event) $script:SourcePath ([TimeSpan]::FromSeconds(10))

        @($segments).Count | Should -Be 1
        $segments[0].Action | Should -Be 'Remove'
        $segments[0].StartSeconds | Should -Be 0.0
        $segments[0].EndSeconds | Should -Be 10.0
    }

}
