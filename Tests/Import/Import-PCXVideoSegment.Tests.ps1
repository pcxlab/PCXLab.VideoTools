Describe 'Import-PCXVideoSegment' {

    BeforeAll {
        . "$PSScriptRoot\..\TestHelper.ps1"
        $script:Module = Get-Module PCXLab.VideoTools
    }

    It 'Imports video segments from a JSON file' {

        $segments = & $script:Module {
            param($TestVideo)
            @(
                New-PCXVideoSegmentObject -SourcePath $TestVideo -Start ([TimeSpan]::Zero) -End ([TimeSpan]::FromSeconds(5)) -Action 'Keep'
                New-PCXVideoSegmentObject -SourcePath $TestVideo -Start ([TimeSpan]::FromSeconds(5)) -End ([TimeSpan]::FromSeconds(10)) -Action 'Remove'
            )
        } $script:TestVideo

        $exported = $segments | Export-PCXVideoSegment -Path "$TestDrive\Test-VideoSegments.json"

        $result = Import-PCXVideoSegment -Path $exported.FullName

        $result | Should -HaveCount 2
        $result[0].PSTypeNames | Should -Contain 'PCXLab.VideoSegment'
        $result[0].Action | Should -Be 'Keep'
        $result[1].Action | Should -Be 'Remove'

    }

}
