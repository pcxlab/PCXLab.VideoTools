BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $script:LegacySessionJson = @'
{
    "MediaSynchronization": [
        {
            "PSTypeName": "PCXLab.MediaSynchronization",
            "Created": "2026-01-27T02:53:49.2530000Z",
            "ModuleVersion": "1.1.0",
            "Sources": [
                {
                    "PSTypeName": "PCXLab.MediaSource",
                    "Path": "C:\\Recordings\\Bandicam.mp4",
                    "Id": "Bandicam",
                    "Label": "Bandicam.mp4",
                    "Role": "Primary",
                    "SourceType": "Video",
                    "AudioStreamIndex": -1,
                    "OffsetHint": null,
                    "MediaInformation": {
                        "PSTypeName": "PCXLab.MediaInformation",
                        "HasAudio": true,
                        "HasVideo": true
                    }
                },
                {
                    "PSTypeName": "PCXLab.MediaSource",
                    "Path": "C:\\Recordings\\Nokia.mp4",
                    "Id": "Nokia",
                    "Label": "Nokia.mp4",
                    "Role": "Primary",
                    "SourceType": "Video",
                    "AudioStreamIndex": -1,
                    "OffsetHint": null,
                    "MediaInformation": {
                        "PSTypeName": "PCXLab.MediaInformation",
                        "HasAudio": true,
                        "HasVideo": true
                    }
                }
            ],
            "Timeline": {
                "PSTypeName": "PCXLab.SynchronizationTimeline",
                "ReferenceId": "Bandicam",
                "ReferencePath": "C:\\Recordings\\Bandicam.mp4",
                "ReferenceDuration": {
                    "Ticks": 30000000000,
                    "Days": 0,
                    "Hours": 0,
                    "Milliseconds": 0,
                    "Minutes": 0,
                    "Seconds": 300,
                    "TotalDays": 0.00034722222222222224,
                    "TotalHours": 0.008333333333333333,
                    "TotalMilliseconds": 300000,
                    "TotalMinutes": 0.5,
                    "TotalSeconds": 300
                },
                "TotalDuration": {
                    "Ticks": 30000000000,
                    "Days": 0,
                    "Hours": 0,
                    "Milliseconds": 0,
                    "Minutes": 0,
                    "Seconds": 300,
                    "TotalDays": 0.00034722222222222224,
                    "TotalHours": 0.008333333333333333,
                    "TotalMilliseconds": 300000,
                    "TotalMinutes": 0.5,
                    "TotalSeconds": 300
                },
                "TotalDurationSeconds": 300,
                "SourceOffsets": [
                    {
                        "PSTypeName": "PCXLab.SourceOffset",
                        "SourceId": "Nokia",
                        "ReferenceId": "Bandicam",
                        "SourcePath": "C:\\Recordings\\Nokia.mp4",
                        "ReferencePath": "C:\\Recordings\\Bandicam.mp4",
                        "OffsetSeconds": 0.5,
                        "Confidence": 0.95,
                        "Method": "AudioCorrelation"
                    }
                ],
                "Segments": []
            },
            "Strategy": "AudioCorrelation",
            "MinimumConfidence": 0.3,
            "MaxOffsetSeconds": null
        }
    ]
}
'@

}

Describe 'RecordingSession Round-Trip' {

    It 'Restores missing behavior properties as Auto on legacy session import' {

        $tempFile = [System.IO.Path]::GetTempFileName()
        try {

            Set-Content -LiteralPath $tempFile -Value $script:LegacySessionJson -Encoding UTF8

            $session = Import-PCXRecordingSession -Path $tempFile

            $session.Sources[0].SynchronizationMethod | Should -Be 'Auto'
            $session.Sources[0].AnalysisMode | Should -Be 'Auto'
            $session.Sources[0].RenderingMode | Should -Be 'Auto'

            $session.Sources[1].SynchronizationMethod | Should -Be 'Auto'
            $session.Sources[1].AnalysisMode | Should -Be 'Auto'
            $session.Sources[1].RenderingMode | Should -Be 'Auto'

        }
        finally {
            Remove-Item -LiteralPath $tempFile -ErrorAction SilentlyContinue
        }

    }

    It 'Round-trips explicit behavior properties through export and import' {

        $ref = New-PCXMediaSource -Path $script:TestVideo -Id Ref -SynchronizationMethod AudioCorrelation -AnalysisMode Enabled -RenderingMode Enabled
        $src = New-PCXMediaSource -Path $script:TestVideo -Id Src -SynchronizationMethod OffsetHint -OffsetHint 0 -AnalysisMode Disabled -RenderingMode Enabled

        $session = @($ref, $src) | Get-PCXRecordingSession -ReferenceSourceId Ref

        $tempFile = [System.IO.Path]::GetTempFileName()
        try {

            $session | Export-PCXRecordingSession -Path $tempFile -Force | Out-Null

            $imported = Import-PCXRecordingSession -Path $tempFile

            $refImported = $imported.Sources | Where-Object { $_.Id -eq 'Ref' } | Select-Object -First 1
            $srcImported = $imported.Sources | Where-Object { $_.Id -eq 'Src' } | Select-Object -First 1

            $refImported.SynchronizationMethod | Should -Be 'AudioCorrelation'
            $refImported.AnalysisMode | Should -Be 'Enabled'
            $refImported.RenderingMode | Should -Be 'Enabled'

            $srcImported.SynchronizationMethod | Should -Be 'OffsetHint'
            $srcImported.AnalysisMode | Should -Be 'Disabled'
            $srcImported.RenderingMode | Should -Be 'Enabled'

        }
        finally {
            Remove-Item -LiteralPath $tempFile -ErrorAction SilentlyContinue
        }

    }

}
