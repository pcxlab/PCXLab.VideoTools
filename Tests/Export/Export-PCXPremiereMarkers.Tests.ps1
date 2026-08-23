Describe 'Export-PCXPremiereMarkers' {

    BeforeAll {
        . "$PSScriptRoot\..\TestHelper.ps1"
        $script:Module = Get-Module PCXLab.VideoTools
    }

    It 'Exports VideoSegment objects to a Premiere marker script' {

        $segments = & $script:Module {
            param($TestVideo)
            @(
                New-PCXVideoSegmentObject -SourcePath $TestVideo -Start ([TimeSpan]::Zero) -End ([TimeSpan]::FromSeconds(5)) -Action 'Keep'
                New-PCXVideoSegmentObject -SourcePath $TestVideo -Start ([TimeSpan]::FromSeconds(5)) -End ([TimeSpan]::FromSeconds(10)) -Action 'Remove'
            )
        } $script:TestVideo

        $result = $segments | Export-PCXPremiereMarkers -Path "$TestDrive\Test-Markers.jsx"

        $result | Should -Not -BeNullOrEmpty
        $result.FullName | Should -Be "$TestDrive\Test-Markers.jsx"
        $result.FullName | Should -Exist

        $scriptContent = Get-Content -LiteralPath $result.FullName -Raw
        $scriptContent | Should -Match 'markerData'
        $scriptContent | Should -Match 'VideoSegment - Keep'
        $scriptContent | Should -Match 'VideoSegment - Remove'

    }

    It 'Exports Silence analysis events to a Premiere marker script' {

        $silence = & $script:Module {
            param($TestVideo)
            @(
                New-PCXSilenceObject -SourcePath $TestVideo -Start ([TimeSpan]::FromSeconds(2)) -End ([TimeSpan]::FromSeconds(8)) -DurationSeconds 6
            )
        } $script:TestVideo

        $result = $silence | Export-PCXPremiereMarkers -Path "$TestDrive\Test-Silence-Markers.jsx"

        $result | Should -Not -BeNullOrEmpty
        $result.FullName | Should -Exist

        $scriptContent = Get-Content -LiteralPath $result.FullName -Raw
        $scriptContent | Should -Match 'Silence - EditCandidate'
        $scriptContent | Should -Match 'Detected silence: 6 seconds'

    }

    It 'Rejects invalid input' {

        $invalid = [PSCustomObject]@{
            InvalidProperty = 'Not an event or segment'
        }

        { $invalid | Export-PCXPremiereMarkers -Path "$TestDrive\Test-Rejected.jsx" } | Should -Throw '*InputObject must be a PCXLab.VideoSegment*'

    }

}
