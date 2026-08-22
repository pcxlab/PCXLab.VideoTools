Describe 'Get-PCXArtifactPath' {

    BeforeAll {
        . "$PSScriptRoot\..\TestHelper.ps1"
        $script:Module = Get-Module PCXLab.VideoTools
    }

    It 'Resolves Analysis artifact path' {
        $result = & $script:Module { Get-PCXArtifactPath -SourcePath 'C:\Temp\Test.mp4' -ArtifactType Analysis }
        $result | Should -Be 'C:\Temp\Test-Analysis.json'
    }

    It 'Resolves Silence artifact path' {
        $result = & $script:Module { Get-PCXArtifactPath -SourcePath 'C:\Temp\Test.mp4' -ArtifactType Silence }
        $result | Should -Be 'C:\Temp\Test-Silence.json'
    }

    It 'Resolves VideoSegment artifact path' {
        $result = & $script:Module { Get-PCXArtifactPath -SourcePath 'C:\Temp\Test.mp4' -ArtifactType VideoSegment }
        $result | Should -Be 'C:\Temp\Test-VideoSegments.json'
    }

    It 'Resolves RecordingSession artifact path using recording group folder' {
        $result = & $script:Module { Get-PCXArtifactPath -SourcePath 'C:\Temp\RG_20260127_025337_004\Test.mp4' -ArtifactType RecordingSession }
        $result | Should -Be 'C:\Temp\RG_20260127_025337_004\RG_20260127_025337_004-RecordingSession.json'
    }

    It 'Resolves PremiereMarker artifact path' {
        $result = & $script:Module { Get-PCXArtifactPath -SourcePath 'C:\Temp\Test.mp4' -ArtifactType PremiereMarker }
        $result | Should -Be 'C:\Temp\Test-PremiereMarkers.jsx'
    }

    It 'Resolves PremiereEditPoint artifact path' {
        $result = & $script:Module { Get-PCXArtifactPath -SourcePath 'C:\Temp\Test.mp4' -ArtifactType PremiereEditPoint }
        $result | Should -Be 'C:\Temp\Test-PremiereEditPoints.jsx'
    }

    It 'Resolves EditedVideo artifact path' {
        $result = & $script:Module { Get-PCXArtifactPath -SourcePath 'C:\Temp\Test.mp4' -ArtifactType EditedVideo }
        $result | Should -Be 'C:\Temp\Test-Edited.mp4'
    }

    It 'Returns explicit OutputPath when provided' {
        $result = & $script:Module { Get-PCXArtifactPath -SourcePath 'C:\Temp\Test.mp4' -ArtifactType Analysis -OutputPath 'C:\Custom\Path.json' }
        $result | Should -Be 'C:\Custom\Path.json'
    }

    It 'Uses OutputDirectory when provided' {
        $result = & $script:Module { Get-PCXArtifactPath -SourcePath 'C:\Temp\Test.mp4' -ArtifactType Analysis -OutputDirectory 'C:\Output' }
        $result | Should -Be 'C:\Output\Test-Analysis.json'
    }

}
