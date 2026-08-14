BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $script:Module = Get-Module PCXLab.VideoTools

    function New-TestMediaSource {
        param(
            [string]$Path = 'C:\test.mp4',
            [string]$Id = 'Test'
        )

        $mediaInfo = [PSCustomObject]@{
            PSTypeName = 'PCXLab.MediaInformation'
            HasAudio   = $true
        }

        $source = [PSCustomObject]@{
            PSTypeName       = 'PCXLab.MediaSource'
            Path             = $Path
            Id               = $Id
            Label            = $Id
            AudioStreamIndex = -1
            MediaInformation = $mediaInfo
        }

        $source
    }

}

Describe 'Measure-PCXSourceOffsetAudioCorrelation duration calculation' {

    It 'Calculates DurationSeconds 190 for MaxOffsetSeconds 60' {

        $ref = New-TestMediaSource -Id 'Reference'
        $src = New-TestMediaSource -Id 'Source'

        $captured = & $script:Module {
            param($ReferenceSource, $TargetSource)

            $script:CapturedDurations = @()

            function Export-PCXAudioCorrelationWav {
                param($Source, $OutputDirectory, $DurationSeconds)
                $script:CapturedDurations += $DurationSeconds
                [PSCustomObject]@{ FullName = Join-Path $OutputDirectory 'test.wav' }
            }

            function Measure-PCXAudioCorrelation {
                param($ReferencePath, $TargetPath, $MaxOffsetSeconds)
                [PSCustomObject]@{
                    PSTypeName  = 'PCXLab.SynchronizationEvidence'
                    Correlation = 0.99
                    PeakSample  = 0
                    SampleRate  = 8000
                }
            }

            $null = Measure-PCXSourceOffsetAudioCorrelation `
                -ReferenceSource $ReferenceSource `
                -TargetSource $TargetSource `
                -MinimumConfidence 0.7 `
                -MaxOffsetSeconds 60 `
                -TempPath $env:TEMP

            $script:CapturedDurations
        } $ref $src

        $captured | Should -Contain 190
        $captured.Count | Should -Be 2

    }

    It 'Calculates DurationSeconds 910 for MaxOffsetSeconds 300' {

        $ref = New-TestMediaSource -Id 'Reference'
        $src = New-TestMediaSource -Id 'Source'

        $captured = & $script:Module {
            param($ReferenceSource, $TargetSource)

            $script:CapturedDurations = @()

            function Export-PCXAudioCorrelationWav {
                param($Source, $OutputDirectory, $DurationSeconds)
                $script:CapturedDurations += $DurationSeconds
                [PSCustomObject]@{ FullName = Join-Path $OutputDirectory 'test.wav' }
            }

            function Measure-PCXAudioCorrelation {
                param($ReferencePath, $TargetPath, $MaxOffsetSeconds)
                [PSCustomObject]@{
                    PSTypeName  = 'PCXLab.SynchronizationEvidence'
                    Correlation = 0.99
                    PeakSample  = 0
                    SampleRate  = 8000
                }
            }

            $null = Measure-PCXSourceOffsetAudioCorrelation `
                -ReferenceSource $ReferenceSource `
                -TargetSource $TargetSource `
                -MinimumConfidence 0.7 `
                -MaxOffsetSeconds 300 `
                -TempPath $env:TEMP

            $script:CapturedDurations
        } $ref $src

        $captured | Should -Contain 910
        $captured.Count | Should -Be 2

    }

}

Describe 'Read-PCXMonoWavSampleBlock duration limit' {

    It 'Accepts DurationSeconds 910' {

        $result = & $script:Module {
            param($TestVideoPath)

            $source = New-PCXMediaSource -Path $TestVideoPath
            $tempPath = Get-PCXSynchronizationTempPath

            try {

                $wav = Export-PCXAudioCorrelationWav `
                    -Source $source `
                    -OutputDirectory $tempPath `
                    -DurationSeconds 910

                $samples = Read-PCXMonoWavSampleBlock `
                    -Path $wav.FullName `
                    -SampleRate 8000 `
                    -StartSeconds 0 `
                    -DurationSeconds 910

                @{ Samples = $samples }

            }
            finally {

                if (Test-Path -LiteralPath $tempPath) {
                    Remove-Item -LiteralPath $tempPath -Recurse -Force
                }

            }

        } $script:TestVideo

        $result.Samples | Should -Not -Be $null

    }

}
