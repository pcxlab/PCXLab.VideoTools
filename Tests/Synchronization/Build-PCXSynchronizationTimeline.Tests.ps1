BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $script:Module = Get-Module PCXLab.VideoTools

}

Describe 'Build-PCXSynchronizationTimeline' {

    It 'Returns a PCXLab.SynchronizationTimeline object' {

        $timeline = & $script:Module {

            param($testVideo)

            $ref = New-PCXMediaSource -Path $testVideo
            $src = New-PCXMediaSource -Path $testVideo

            $offset = New-PCXSourceOffsetObject `
                -SourceId $src.Id `
                -ReferenceId $ref.Id `
                -SourcePath $src.Path `
                -ReferencePath $ref.Path `
                -OffsetSeconds 0 `
                -Confidence 0.95 `
                -Method 'AudioCorrelation' `
                -Evidence $null

            Build-PCXSynchronizationTimeline `
                -ReferenceSource $ref `
                -Sources @($ref, $src) `
                -SourceOffsets @($offset)

        } $script:TestVideo

        $timeline.PSTypeNames[0] | Should -Be 'PCXLab.SynchronizationTimeline'

    }

    It 'Includes a reference contribution while the reference is active' {

        $timeline = & $script:Module {

            param($testVideo)

            $ref = New-PCXMediaSource -Path $testVideo
            $src = New-PCXMediaSource -Path $testVideo

            $offset = New-PCXSourceOffsetObject `
                -SourceId $src.Id `
                -ReferenceId $ref.Id `
                -SourcePath $src.Path `
                -ReferencePath $ref.Path `
                -OffsetSeconds 0 `
                -Confidence 0.95 `
                -Method 'AudioCorrelation' `
                -Evidence $null

            Build-PCXSynchronizationTimeline `
                -ReferenceSource $ref `
                -Sources @($ref, $src) `
                -SourceOffsets @($offset)

        } $script:TestVideo

        foreach ($segment in $timeline.Segments) {
            $segment.Contributions.SourcePath | Should -Contain $timeline.ReferencePath
        }

    }

    It 'Excludes the reference contribution after the reference duration' {

        $timeline = & $script:Module {

            param($testVideo)

            $ref = New-PCXMediaSource -Path $testVideo
            $src = New-PCXMediaSource -Path $testVideo

            $offset = New-PCXSourceOffsetObject `
                -SourceId $src.Id `
                -ReferenceId $ref.Id `
                -SourcePath $src.Path `
                -ReferencePath $ref.Path `
                -OffsetSeconds -5 `
                -Confidence 0.95 `
                -Method 'AudioCorrelation' `
                -Evidence $null

            Build-PCXSynchronizationTimeline `
                -ReferenceSource $ref `
                -Sources @($ref, $src) `
                -SourceOffsets @($offset)

        } $script:TestVideo

        $timeline.TotalDurationSeconds | Should -BeGreaterThan $timeline.ReferenceDuration

        $lastSegment = $timeline.Segments | Sort-Object EndSeconds | Select-Object -Last 1

        $lastSegment.EndSeconds | Should -BeGreaterThan $timeline.ReferenceDuration

        $lastSegment.Contributions.OffsetSeconds | Should -Not -Contain 0

    }

    It 'Creates one segment when only the reference is present' {

        $timeline = & $script:Module {

            param($testVideo)

            $ref = New-PCXMediaSource -Path $testVideo

            Build-PCXSynchronizationTimeline `
                -ReferenceSource $ref `
                -Sources @($ref) `
                -SourceOffsets @()

        } $script:TestVideo

        $timeline.Segments.Count | Should -Be 1
        $timeline.Segments[0].Contributions.Count | Should -Be 1

    }

}