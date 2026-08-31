Describe 'Copy-PCXAnalysisEventClone' {

    BeforeAll {
        . "$PSScriptRoot\..\TestHelper.ps1"
        $module = Get-Module PCXLab.VideoTools
    }

    It 'Creates a new object distinct from the original' {
        $original = [PSCustomObject]@{
            PSTypeName      = 'PCXLab.Silence'
            SourcePath      = 'C:\Media\Video.mp4'
            Source           = 'Video.mp4'
            Start           = [TimeSpan]::FromSeconds(1)
            End             = [TimeSpan]::FromSeconds(5)
            Duration        = [TimeSpan]::FromSeconds(4)
            StartSeconds    = 1.0
            EndSeconds      = 5.0
            DurationSeconds = 4.0
            EventType       = 'Silence'
        }

        $clone = & $module {
            param($obj)
            Copy-PCXAnalysisEventClone -InputObject $obj
        } $original

        $clone | Should -Not -Be $null
        [object]::ReferenceEquals($clone, $original) | Should -Be $false
    }

    It 'Preserves all NoteProperty values' {
        $original = [PSCustomObject]@{
            PSTypeName      = 'PCXLab.Silence'
            SourcePath      = 'C:\Media\Video.mp4'
            Source           = 'Video.mp4'
            Start           = [TimeSpan]::FromSeconds(2)
            End             = [TimeSpan]::FromSeconds(6)
            Duration        = [TimeSpan]::FromSeconds(4)
            StartSeconds    = 2.0
            EndSeconds      = 6.0
            DurationSeconds = 4.0
            EventType       = 'Silence'
            CustomMetadata  = 'TestValue'
        }

        $clone = & $module {
            param($obj)
            Copy-PCXAnalysisEventClone -InputObject $obj
        } $original

        $clone.SourcePath      | Should -Be 'C:\Media\Video.mp4'
        $clone.Source           | Should -Be 'Video.mp4'
        $clone.Start           | Should -Be ([TimeSpan]::FromSeconds(2))
        $clone.End             | Should -Be ([TimeSpan]::FromSeconds(6))
        $clone.Duration        | Should -Be ([TimeSpan]::FromSeconds(4))
        $clone.StartSeconds    | Should -Be 2.0
        $clone.EndSeconds      | Should -Be 6.0
        $clone.DurationSeconds | Should -Be 4.0
        $clone.EventType       | Should -Be 'Silence'
        $clone.CustomMetadata  | Should -Be 'TestValue'
    }

    It 'Preserves custom PSTypeNames' {
        $original = [PSCustomObject]@{
            PSTypeName      = 'PCXLab.BlackFrame'
            SourcePath      = 'C:\Media\Video.mp4'
            Source           = 'Video.mp4'
            Start           = [TimeSpan]::FromSeconds(0)
            End             = [TimeSpan]::FromSeconds(1)
            Duration        = [TimeSpan]::FromSeconds(1)
            StartSeconds    = 0.0
            EndSeconds      = 1.0
            DurationSeconds = 1.0
            EventType       = 'BlackFrame'
        }

        $clone = & $module {
            param($obj)
            Copy-PCXAnalysisEventClone -InputObject $obj
        } $original

        $clone.PSTypeNames | Should -Contain 'PCXLab.BlackFrame'
    }

    It 'Allows mutation of clone without affecting original' {
        $original = [PSCustomObject]@{
            PSTypeName      = 'PCXLab.Silence'
            SourcePath      = 'C:\Media\Video.mp4'
            Source           = 'Video.mp4'
            Start           = [TimeSpan]::FromSeconds(1)
            End             = [TimeSpan]::FromSeconds(5)
            Duration        = [TimeSpan]::FromSeconds(4)
            StartSeconds    = 1.0
            EndSeconds      = 5.0
            DurationSeconds = 4.0
            EventType       = 'Silence'
        }

        $clone = & $module {
            param($obj)
            Copy-PCXAnalysisEventClone -InputObject $obj
        } $original

        $clone.StartSeconds = 99.0
        $original.StartSeconds | Should -Be 1.0
    }

    It 'Handles events with extra payload properties' {
        $original = [PSCustomObject]@{
            PSTypeName      = 'PCXLab.WhisperTranscript'
            SourcePath      = 'C:\Media\Video.mp4'
            Source           = 'Video.mp4'
            Start           = [TimeSpan]::FromSeconds(0)
            End             = [TimeSpan]::FromSeconds(3)
            Duration        = [TimeSpan]::FromSeconds(3)
            StartSeconds    = 0.0
            EndSeconds      = 3.0
            DurationSeconds = 3.0
            EventType       = 'Whisper'
            Text            = 'Hello world'
            Confidence      = 0.95
        }

        $clone = & $module {
            param($obj)
            Copy-PCXAnalysisEventClone -InputObject $obj
        } $original

        $clone.Text       | Should -Be 'Hello world'
        $clone.Confidence | Should -Be 0.95
        $clone.PSTypeNames | Should -Contain 'PCXLab.WhisperTranscript'
    }

}
