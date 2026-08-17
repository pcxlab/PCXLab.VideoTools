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

    It 'Rejects mixed input types' {

        $segment = & $script:Module {
            param($TestVideo)
            New-PCXVideoSegmentObject -SourcePath $TestVideo -Start ([TimeSpan]::Zero) -End ([TimeSpan]::FromSeconds(5)) -Action 'Keep'
        } $script:TestVideo

        $silence = New-Object PSObject -Property @{
            SourcePath = $script:TestVideo
            Start      = [TimeSpan]::Zero
            End        = [TimeSpan]::FromSeconds(5)
            Duration   = [TimeSpan]::FromSeconds(5)
        }
        $silence.PSTypeNames.Insert(0, 'PCXLab.Silence')

        $mixed = @($segment, $silence)

        { $mixed | Export-PCXPremiereMarkers -Path "$TestDrive\Test-Mixed.jsx" } | Should -Throw '*same type*'

    }

}
