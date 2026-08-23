BeforeAll {
    . "$PSScriptRoot\..\TestHelper.ps1"
    $script:Module = Get-Module PCXLab.VideoTools
}

Describe 'ConvertTo-PCXPremiereMarker' {

    It 'Converts PCXLab.VideoSegment to normalized PCXLab.PremiereMarker' {
        $segment = & $script:Module {
            param($TestVideo)
            New-PCXVideoSegmentObject `
                -SourcePath $TestVideo `
                -Start ([TimeSpan]::FromSeconds(2)) `
                -End ([TimeSpan]::FromSeconds(8)) `
                -Action 'Keep'
        } $script:TestVideo

        $marker = & $script:Module {
            param($seg)
            ConvertTo-PCXPremiereMarker -InputObject $seg
        } $segment

        $marker | Should -Not -BeNullOrEmpty
        $marker.PSTypeNames | Should -Contain 'PCXLab.PremiereMarker'
        $marker.StartSeconds | Should -Be 2.0
        $marker.EndSeconds | Should -Be 8.0
        $marker.DurationSeconds | Should -Be 6.0
        $marker.Name | Should -Be 'VideoSegment - Keep'
        $marker.Comments | Should -Match 'Detected segment: 6 seconds. Action: Keep.'
    }

    It 'Converts PCXLab.Silence to normalized PCXLab.PremiereMarker with factual classification' {
        $silence = & $script:Module {
            param($TestVideo)
            New-PCXSilenceObject `
                -Start ([TimeSpan]::FromSeconds(10)) `
                -End ([TimeSpan]::FromSeconds(30)) `
                -DurationSeconds 20 `
                -SourcePath $TestVideo
        } $script:TestVideo

        $marker = & $script:Module {
            param($sil)
            ConvertTo-PCXPremiereMarker -InputObject $sil
        } $silence

        $marker | Should -Not -BeNullOrEmpty
        $marker.PSTypeNames | Should -Contain 'PCXLab.PremiereMarker'
        $marker.StartSeconds | Should -Be 10.0
        $marker.EndSeconds | Should -Be 30.0
        $marker.DurationSeconds | Should -Be 20.0
        $marker.Name | Should -Be 'Silence - RecordingBreak'
        $marker.Comments | Should -Match 'Detected silence: 20 seconds. Classification: RecordingBreak.'
    }

    It 'Converts PCXLab.BlackFrame to normalized PCXLab.PremiereMarker' {
        $blackFrame = & $script:Module {
            param($TestVideo)
            New-PCXBlackFrameObject `
                -Start ([TimeSpan]::FromSeconds(5)) `
                -End ([TimeSpan]::FromSeconds(7.5)) `
                -DurationSeconds 2.5 `
                -SourcePath $TestVideo
        } $script:TestVideo

        $marker = & $script:Module {
            param($bf)
            ConvertTo-PCXPremiereMarker -InputObject $bf
        } $blackFrame

        $marker | Should -Not -BeNullOrEmpty
        $marker.PSTypeNames | Should -Contain 'PCXLab.PremiereMarker'
        $marker.StartSeconds | Should -Be 5.0
        $marker.EndSeconds | Should -Be 7.5
        $marker.DurationSeconds | Should -Be 2.5
        $marker.Name | Should -Be 'BlackFrame'
        $marker.Comments | Should -Match 'Detected black frames: 2.5 seconds.'
    }

    It 'Unpacks PCXLab.VideoAnalysis into constituent markers' {
        $analysis = & $script:Module {
            param($TestVideo)
            $sil = New-PCXSilenceObject `
                -Start ([TimeSpan]::FromSeconds(1)) `
                -End ([TimeSpan]::FromSeconds(3)) `
                -DurationSeconds 2 `
                -SourcePath $TestVideo

            $bf = New-PCXBlackFrameObject `
                -Start ([TimeSpan]::FromSeconds(4)) `
                -End ([TimeSpan]::FromSeconds(6)) `
                -DurationSeconds 2 `
                -SourcePath $TestVideo

            New-PCXVideoAnalysisObject `
                -SourcePath $TestVideo `
                -Media ([PSCustomObject]@{ DurationSeconds = 10 }) `
                -Silence @($sil) `
                -BlackFrames @($bf)
        } $script:TestVideo

        $markers = & $script:Module {
            param($ana)
            @(ConvertTo-PCXPremiereMarker -InputObject $ana)
        } $analysis

        $markers.Count | Should -Be 2
        $markers[0].Name | Should -Be 'Silence - ShortPause'
        $markers[1].Name | Should -Be 'BlackFrame'
    }

    It 'Throws descriptive error for unsupported input' {
        {
            & $script:Module {
                ConvertTo-PCXPremiereMarker -InputObject "Not an event or segment"
            }
        } | Should -Throw '*InputObject must be a PCXLab.VideoSegment, PCXLab.VideoAnalysis, or valid PCXLab Analysis Event*'
    }

}
