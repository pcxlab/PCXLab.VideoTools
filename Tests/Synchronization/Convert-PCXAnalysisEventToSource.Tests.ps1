BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $script:Module = Get-Module PCXLab.VideoTools

}

Describe 'Convert-PCXAnalysisEventToSource' {

    Context 'Translating Silence Events' {

        It 'Translates PCXLab.Silence events with offset and preserves contract' {

            $results = & $script:Module {

                $silence = New-PCXSilenceObject `
                    -SourcePath 'C:\Videos\Camera1.mp4' `
                    -Start ([TimeSpan]::FromSeconds(10)) `
                    -End ([TimeSpan]::FromSeconds(20)) `
                    -DurationSeconds 10

                $offset = New-PCXSourceOffsetObject `
                    -SourceId 'Cam2' `
                    -ReferenceId 'Cam1' `
                    -SourcePath 'C:\Videos\Camera2.mp4' `
                    -ReferencePath 'C:\Videos\Camera1.mp4' `
                    -OffsetSeconds 2.5

                Convert-PCXAnalysisEventToSource -Event $silence -SourceOffset $offset

            }

            $results | Should -Not -BeNullOrEmpty
            $results.SourcePath | Should -Be 'C:\Videos\Camera2.mp4'
            $results.Source | Should -Be 'Camera2.mp4'
            $results.EventType | Should -Be 'Silence'
            $results.Start | Should -Be ([TimeSpan]::FromSeconds(7.5))
            $results.End | Should -Be ([TimeSpan]::FromSeconds(17.5))
            $results.Duration | Should -Be ([TimeSpan]::FromSeconds(10.0))
            $results.StartSeconds | Should -Be 7.5
            $results.EndSeconds | Should -Be 17.5
            $results.DurationSeconds | Should -Be 10.0
            $results.Classification | Should -Be 'EditCandidate'
            $results.PSTypeNames | Should -Contain 'PCXLab.Silence'

            (& $script:Module { Test-PCXAnalysisEvent -InputObject $args[0] } $results) | Should -BeTrue

        }

    }

    Context 'Translating BlackFrame Events' {

        It 'Translates PCXLab.BlackFrame events with offset and preserves contract' {

            $results = & $script:Module {

                $blackFrame = New-PCXBlackFrameObject `
                    -SourcePath 'C:\Videos\Camera1.mp4' `
                    -Start ([TimeSpan]::FromSeconds(15)) `
                    -End ([TimeSpan]::FromSeconds(18)) `
                    -DurationSeconds 3

                Convert-PCXAnalysisEventToSource `
                    -Event $blackFrame `
                    -SourcePath 'C:\Videos\Camera2.mp4' `
                    -OffsetSeconds 5.0

            }

            $results | Should -Not -BeNullOrEmpty
            $results.SourcePath | Should -Be 'C:\Videos\Camera2.mp4'
            $results.EventType | Should -Be 'BlackFrame'
            $results.Start | Should -Be ([TimeSpan]::FromSeconds(10))
            $results.End | Should -Be ([TimeSpan]::FromSeconds(13))
            $results.Duration | Should -Be ([TimeSpan]::FromSeconds(3))
            $results.PSTypeNames | Should -Contain 'PCXLab.BlackFrame'

            (& $script:Module { Test-PCXAnalysisEvent -InputObject $args[0] } $results) | Should -BeTrue

        }

    }

    Context 'Translating Custom Analysis Events' {

        It 'Translates custom events satisfying Test-PCXAnalysisEvent and preserves extra properties' {

            $results = & $script:Module {

                $customEvent = [PSCustomObject]@{
                    PSTypeName      = 'PCXLab.CustomEvent'
                    EventType       = 'Custom'
                    SourcePath      = 'C:\Videos\Camera1.mp4'
                    Source          = 'Camera1.mp4'
                    Start           = [TimeSpan]::FromSeconds(30)
                    End             = [TimeSpan]::FromSeconds(45)
                    Duration        = [TimeSpan]::FromSeconds(15)
                    Confidence      = 0.95
                    CustomMetadata  = 'Speaker1'
                }

                Convert-PCXAnalysisEventToSource `
                    -Event $customEvent `
                    -SourcePath 'C:\Videos\Camera2.mp4' `
                    -OffsetSeconds 10.0

            }

            $results | Should -Not -BeNullOrEmpty
            $results.SourcePath | Should -Be 'C:\Videos\Camera2.mp4'
            $results.EventType | Should -Be 'Custom'
            $results.Start | Should -Be ([TimeSpan]::FromSeconds(20))
            $results.End | Should -Be ([TimeSpan]::FromSeconds(35))
            $results.Duration | Should -Be ([TimeSpan]::FromSeconds(15))
            $results.Confidence | Should -Be 0.95
            $results.CustomMetadata | Should -Be 'Speaker1'

            (& $script:Module { Test-PCXAnalysisEvent -InputObject $args[0] } $results) | Should -BeTrue

        }

    }

    Context 'Boundary Clamping and Discarding' {

        It 'Clamps start to zero when event begins before target media started' {

            $results = & $script:Module {

                $silence = New-PCXSilenceObject `
                    -SourcePath 'C:\Videos\Camera1.mp4' `
                    -Start ([TimeSpan]::FromSeconds(2)) `
                    -End ([TimeSpan]::FromSeconds(8)) `
                    -DurationSeconds 6

                Convert-PCXAnalysisEventToSource `
                    -Event $silence `
                    -SourcePath 'C:\Videos\Camera2.mp4' `
                    -OffsetSeconds 4.0

            }

            $results | Should -Not -BeNullOrEmpty
            $results.Start | Should -Be ([TimeSpan]::Zero)
            $results.End | Should -Be ([TimeSpan]::FromSeconds(4.0))
            $results.Duration | Should -Be ([TimeSpan]::FromSeconds(4.0))
            $results.StartSeconds | Should -Be 0
            $results.EndSeconds | Should -Be 4.0
            $results.DurationSeconds | Should -Be 4.0

        }

        It 'Discards events that end before or at target media start' {

            $results = & $script:Module {

                $silence = New-PCXSilenceObject `
                    -SourcePath 'C:\Videos\Camera1.mp4' `
                    -Start ([TimeSpan]::FromSeconds(1)) `
                    -End ([TimeSpan]::FromSeconds(4)) `
                    -DurationSeconds 3

                Convert-PCXAnalysisEventToSource `
                    -Event $silence `
                    -SourcePath 'C:\Videos\Camera2.mp4' `
                    -OffsetSeconds 5.0

            }

            $results | Should -BeNullOrEmpty

        }

    }

    Context 'Pipeline Support and Multiple Events' {

        It 'Processes multiple events through pipeline and filters out of bounds events' {

            $results = & $script:Module {

                $evt1 = New-PCXSilenceObject `
                    -SourcePath 'C:\Videos\Camera1.mp4' `
                    -Start ([TimeSpan]::FromSeconds(1)) `
                    -End ([TimeSpan]::FromSeconds(3)) `
                    -DurationSeconds 2

                $evt2 = New-PCXSilenceObject `
                    -SourcePath 'C:\Videos\Camera1.mp4' `
                    -Start ([TimeSpan]::FromSeconds(10)) `
                    -End ([TimeSpan]::FromSeconds(15)) `
                    -DurationSeconds 5

                @($evt1, $evt2) | Convert-PCXAnalysisEventToSource `
                    -SourcePath 'C:\Videos\Camera2.mp4' `
                    -OffsetSeconds 4.0

            }

            @($results).Count | Should -Be 1
            $results[0].Start | Should -Be ([TimeSpan]::FromSeconds(6))
            $results[0].End | Should -Be ([TimeSpan]::FromSeconds(11))

        }

    }

    Context 'Validation' {

        It 'Throws when input object does not conform to analysis event contract' {

            {
                & $script:Module {
                    Convert-PCXAnalysisEventToSource `
                        -Event ([PSCustomObject]@{ Invalid = 'Object' }) `
                        -SourcePath 'C:\Videos\Camera2.mp4' `
                        -OffsetSeconds 0
                }
            } | Should -Throw

        }

    }

}
