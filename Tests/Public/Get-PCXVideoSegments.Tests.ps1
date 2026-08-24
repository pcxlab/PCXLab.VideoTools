Describe 'Get-PCXVideoSegments' {

    BeforeAll {
        . "$PSScriptRoot\..\TestHelper.ps1"
        $module = Get-Module PCXLab.VideoTools
        $script:CheckpointFile = & $module {
            param($Source)
            Get-PCXArtifactPath -SourcePath $Source -ArtifactType VideoSegment
        } $script:TestVideo
    }

    BeforeEach {
        if (Test-Path -LiteralPath $script:CheckpointFile) {
            Remove-Item -LiteralPath $script:CheckpointFile -Force -ErrorAction SilentlyContinue
        }
    }

    AfterAll {
        if (Test-Path -LiteralPath $script:CheckpointFile) {
            Remove-Item -LiteralPath $script:CheckpointFile -Force -ErrorAction SilentlyContinue
        }
    }

    It 'Builds Keep and Remove segments from PCXLab.Silence events' {
        $silence = @(
            Find-PCXSilence -Path $script:TestVideo -MinimumDuration 2 -NoiseFloor -35
        )

        $segments = @($silence | Get-PCXVideoSegments)
        $segments.Count | Should -BeGreaterThan 0
        $segments[0].PSTypeNames[0] | Should -Be 'PCXLab.VideoSegment'
        @($segments | Where-Object Action -eq 'Keep').Count | Should -BeGreaterThan 0
        @($segments | Where-Object Action -eq 'Remove').Count | Should -BeGreaterThan 0
    }

    It 'Builds Keep and Remove segments from PCXLab.BlackFrame events' {
        $blackFrames = @(
            Find-PCXBlackFrames -Path $script:TestVideo
        )

        $segments = @($blackFrames | Get-PCXVideoSegments)
        $segments.Count | Should -BeGreaterThan 0
        $segments[0].PSTypeNames[0] | Should -Be 'PCXLab.VideoSegment'
        @($segments | Where-Object Action -eq 'Keep').Count | Should -BeGreaterThan 0
        @($segments | Where-Object Action -eq 'Remove').Count | Should -BeGreaterThan 0
    }

    It 'Builds Keep and Remove segments from a complete PCXLab.VideoAnalysis container' {
        $analysis = & $module {
            param($TestVideo)

            $sil = New-PCXSilenceObject `
                -Start ([TimeSpan]::FromSeconds(2)) `
                -End ([TimeSpan]::FromSeconds(5)) `
                -DurationSeconds 3 `
                -SourcePath $TestVideo

            New-PCXVideoAnalysisObject `
                -SourcePath $TestVideo `
                -Media ([PSCustomObject]@{ DurationSeconds = 10 }) `
                -Silence @($sil)
        } $script:TestVideo

        $segments = @($analysis | Get-PCXVideoSegments)
        $segments.Count | Should -BeGreaterThan 1
        $segments[0].Action | Should -Be 'Keep'
        $segments[1].Action | Should -Be 'Remove'
    }

    It 'Builds Keep and Remove segments from a custom future analysis event' {
        $customEvent = [PSCustomObject]@{
            SourcePath = $script:TestVideo
            Start      = [TimeSpan]::FromSeconds(2)
            End        = [TimeSpan]::FromSeconds(5)
            Duration   = [TimeSpan]::FromSeconds(3)
            EventType  = 'SceneChange'
        }

        $segments = @($customEvent | Get-PCXVideoSegments)
        $segments.Count | Should -BeGreaterThan 1
        $segments[0].Action | Should -Be 'Keep'
        $segments[0].Start | Should -Be ([TimeSpan]::Zero)
        $segments[0].End | Should -Be ([TimeSpan]::FromSeconds(2))

        $segments[1].Action | Should -Be 'Remove'
        $segments[1].Start | Should -Be ([TimeSpan]::FromSeconds(2))
        $segments[1].End | Should -Be ([TimeSpan]::FromSeconds(5))
    }

    It 'Exports VideoSegments.json on cache miss and reuses it on cache hit' {
        $customEvent = [PSCustomObject]@{
            SourcePath = $script:TestVideo
            Start      = [TimeSpan]::FromSeconds(2)
            End        = [TimeSpan]::FromSeconds(5)
            Duration   = [TimeSpan]::FromSeconds(3)
            EventType  = 'SceneChange'
        }

        # Run 1: Cache Miss -> Generates segments and writes VideoSegments.json
        (Test-Path -LiteralPath $script:CheckpointFile) | Should -Be $false
        $segmentsRun1 = @($customEvent | Get-PCXVideoSegments)
        (Test-Path -LiteralPath $script:CheckpointFile) | Should -Be $true
        $segmentsRun1.Count | Should -BeGreaterThan 0

        # Run 2: Cache Hit -> Loads VideoSegments.json directly
        $segmentsRun2 = @($customEvent | Get-PCXVideoSegments)
        $segmentsRun2.Count | Should -Be $segmentsRun1.Count
        $segmentsRun2[0].PSTypeNames[0] | Should -Be 'PCXLab.VideoSegment'
        $segmentsRun2[0].Start | Should -Be $segmentsRun1[0].Start
        $segmentsRun2[0].Action | Should -Be $segmentsRun1[0].Action
    }

    It 'Throws a descriptive error when an invalid object is supplied' {
        $invalid = [PSCustomObject]@{
            SomeRandomField = 123
        }

        { $invalid | Get-PCXVideoSegments } | Should -Throw '*contract*'
    }

}
