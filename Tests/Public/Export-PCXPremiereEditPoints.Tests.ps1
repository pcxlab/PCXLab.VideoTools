BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $module = Get-Module PCXLab.VideoTools

    #
    # Create silence events with SourcePath and convert to VideoSegments.
    # The editing pipeline is now: Analysis Events → Get-PCXVideoSegments → Exporters.
    #

    $script:Segments = & $module {
        param($TestVideo)

        $silence = New-PCXSilenceObject `
            -Start ([TimeSpan]::FromSeconds(10)) `
            -End ([TimeSpan]::FromSeconds(16)) `
            -DurationSeconds 6 `
            -SourcePath $TestVideo

        $silence | Get-PCXVideoSegments
    } $script:TestVideo
}

Describe 'Export-PCXPremiereEditPoints' {

    It 'Creates a Premiere edit-point ExtendScript file' {
        $outputPath = Join-Path $TestDrive 'EditPoints.jsx'

        $script:Segments |
            Export-PCXPremiereEditPoints -OutputPath $outputPath | Should -Exist
    }

    It 'Produces valid ExtendScript content' {
        $outputPath = Join-Path $TestDrive 'EditPointContent.jsx'

        $script:Segments |
            Export-PCXPremiereEditPoints -OutputPath $outputPath | Out-Null

        $content = Get-Content -LiteralPath $outputPath -Raw

        $content | Should -Match '#target premierepro'
        $content | Should -Match 'editPoints'
        $content | Should -Match 'razor'
    }

    It 'Rejects non-VideoSegment input' {
        $silence = & (Get-Module PCXLab.VideoTools) {
            param($TestVideo)
            New-PCXSilenceObject `
                -Start ([TimeSpan]::FromSeconds(10)) `
                -End ([TimeSpan]::FromSeconds(16)) `
                -DurationSeconds 6 `
                -SourcePath $TestVideo
        } $script:TestVideo

        { $silence | Export-PCXPremiereEditPoints -Path "$TestDrive\Rejected.jsx" } |
            Should -Throw '*PCXLab.VideoSegment*'
    }

    It 'Generates default output path when -Path is omitted' {
        $segment = & (Get-Module PCXLab.VideoTools) {
            param($TestVideo)
            New-PCXVideoSegmentObject `
                -SourcePath $TestVideo `
                -Start ([TimeSpan]::Zero) `
                -End ([TimeSpan]::FromSeconds(5)) `
                -Action 'Keep'
        } $script:TestVideo

        $expectedPath = Join-Path (Split-Path $script:TestVideo -Parent) 'Test-PremiereEditPoints.jsx'
        if (Test-Path $expectedPath) { Remove-Item $expectedPath -Force }

        $result = $segment | Export-PCXPremiereEditPoints
        $result.FullName | Should -Be $expectedPath
        $expectedPath | Should -Exist

        # Clean up generated file
        Remove-Item $expectedPath -Force -ErrorAction SilentlyContinue
    }
}
