Describe 'Export-PCXVideoSegment' {

    BeforeAll {
        . "$PSScriptRoot\..\TestHelper.ps1"
        $script:Module = Get-Module PCXLab.VideoTools
    }

    It 'Exports video segments to a JSON file' {

        $segments = & $script:Module {
            param($TestVideo)
            @(
                New-PCXVideoSegmentObject -SourcePath $TestVideo -Start ([TimeSpan]::Zero) -End ([TimeSpan]::FromSeconds(5)) -Action 'Keep'
                New-PCXVideoSegmentObject -SourcePath $TestVideo -Start ([TimeSpan]::FromSeconds(5)) -End ([TimeSpan]::FromSeconds(10)) -Action 'Remove'
            )
        } $script:TestVideo

        $result = $segments | Export-PCXVideoSegment -Path "$TestDrive\Test-VideoSegments.json"

        $result | Should -Not -BeNullOrEmpty
        $result.FullName | Should -Be "$TestDrive\Test-VideoSegments.json"
        $result.FullName | Should -Exist

        $json = Get-Content -LiteralPath $result.FullName -Raw | ConvertFrom-Json
        $json.VideoSegments | Should -HaveCount 2
        $json.VideoSegments[0].Action | Should -Be 'Keep'
        $json.VideoSegments[1].Action | Should -Be 'Remove'

    }

    It 'Generates default output path when -Path is omitted' {

        $segments = & $script:Module {
            param($TestVideo)
            @(
                New-PCXVideoSegmentObject -SourcePath $TestVideo -Start ([TimeSpan]::Zero) -End ([TimeSpan]::FromSeconds(5)) -Action 'Keep'
            )
        } $script:TestVideo

        $expectedPath = Join-Path ([System.IO.Path]::GetDirectoryName($script:TestVideo)) 'Test-VideoSegments.json'
        if (Test-Path $expectedPath) { Remove-Item $expectedPath -Force }

        $result = $segments | Export-PCXVideoSegment

        $result.FullName | Should -Be $expectedPath

    }

}
