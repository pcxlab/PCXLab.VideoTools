Describe 'Restore-PCXAnalysisEventTimeSpans' {

    BeforeAll {
        . "$PSScriptRoot\..\TestHelper.ps1"
        $module = Get-Module PCXLab.VideoTools
    }

    It 'Restores TimeSpan properties from deserialized Ticks' {
        # Simulate what ConvertFrom-Json produces for TimeSpan values
        $item = [PSCustomObject]@{
            Start    = [PSCustomObject]@{ Ticks = [TimeSpan]::FromSeconds(1.5).Ticks }
            End      = [PSCustomObject]@{ Ticks = [TimeSpan]::FromSeconds(4.0).Ticks }
            Duration = [PSCustomObject]@{ Ticks = [TimeSpan]::FromSeconds(2.5).Ticks }
        }

        & $module {
            param($items)
            Restore-PCXAnalysisEventTimeSpans -Items $items -TypeName 'PCXLab.Silence'
        } @($item)

        $item.Start    | Should -BeOfType [TimeSpan]
        $item.End      | Should -BeOfType [TimeSpan]
        $item.Duration | Should -BeOfType [TimeSpan]
        $item.Start.TotalSeconds    | Should -Be 1.5
        $item.End.TotalSeconds      | Should -Be 4.0
        $item.Duration.TotalSeconds | Should -Be 2.5
    }

    It 'Inserts the correct PSTypeName' {
        $item = [PSCustomObject]@{
            Start    = [PSCustomObject]@{ Ticks = 0 }
            End      = [PSCustomObject]@{ Ticks = 10000000 }
            Duration = [PSCustomObject]@{ Ticks = 10000000 }
        }

        & $module {
            param($items)
            Restore-PCXAnalysisEventTimeSpans -Items $items -TypeName 'PCXLab.BlackFrame'
        } @($item)

        $item.PSTypeNames | Should -Contain 'PCXLab.BlackFrame'
    }

    It 'Does not duplicate the type name when already present' {
        $item = [PSCustomObject]@{
            PSTypeName = 'PCXLab.Silence'
            Start      = [PSCustomObject]@{ Ticks = 0 }
            End        = [PSCustomObject]@{ Ticks = 10000000 }
            Duration   = [PSCustomObject]@{ Ticks = 10000000 }
        }

        & $module {
            param($items)
            Restore-PCXAnalysisEventTimeSpans -Items $items -TypeName 'PCXLab.Silence'
        } @($item)

        $silenceTypeCount = @($item.PSTypeNames | Where-Object { $_ -eq 'PCXLab.Silence' }).Count
        $silenceTypeCount | Should -Be 1
    }

    It 'Processes multiple items in one call' {
        $items = @(
            [PSCustomObject]@{
                Start    = [PSCustomObject]@{ Ticks = [TimeSpan]::FromSeconds(1).Ticks }
                End      = [PSCustomObject]@{ Ticks = [TimeSpan]::FromSeconds(2).Ticks }
                Duration = [PSCustomObject]@{ Ticks = [TimeSpan]::FromSeconds(1).Ticks }
            },
            [PSCustomObject]@{
                Start    = [PSCustomObject]@{ Ticks = [TimeSpan]::FromSeconds(5).Ticks }
                End      = [PSCustomObject]@{ Ticks = [TimeSpan]::FromSeconds(8).Ticks }
                Duration = [PSCustomObject]@{ Ticks = [TimeSpan]::FromSeconds(3).Ticks }
            }
        )

        & $module {
            param($items)
            Restore-PCXAnalysisEventTimeSpans -Items $items -TypeName 'PCXLab.Silence'
        } $items

        $items[0].Start | Should -BeOfType [TimeSpan]
        $items[0].End   | Should -BeOfType [TimeSpan]
        $items[1].Start.TotalSeconds | Should -Be 5.0
        $items[1].End.TotalSeconds   | Should -Be 8.0
    }

    It 'Handles null Items gracefully' {
        {
            & $module {
                Restore-PCXAnalysisEventTimeSpans -Items $null -TypeName 'PCXLab.Silence'
            }
        } | Should -Not -Throw
    }

    It 'Handles empty collection gracefully' {
        {
            & $module {
                Restore-PCXAnalysisEventTimeSpans -Items @() -TypeName 'PCXLab.Silence'
            }
        } | Should -Not -Throw
    }

}
