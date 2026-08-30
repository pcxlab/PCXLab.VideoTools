BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $script:Module = Get-Module PCXLab.VideoTools

}

Describe 'Get-PCXAudioActivity' {

    It 'Returns expected output object structure' {

        $activity = & $script:Module {
            param($path)
            Get-PCXAudioActivity -Path $path
        } $script:TestVideo

        $activity | Should -Not -BeNullOrEmpty
        $activity.FrameRate | Should -Be 100
        $activity.FrameDuration | Should -Be 0.01
        $activity.AudioSampleRate | Should -Be 8000
        $activity.Frames | Should -Not -BeNullOrEmpty

    }

    It 'Calculates expected frame count based on media duration' {

        $audioInfo = Get-PCXAudioInformation -Path $script:TestVideo
        $expectedDuration = $audioInfo.Duration.TotalSeconds

        $activity = & $script:Module {
            param($path)
            Get-PCXAudioActivity -Path $path -FrameDuration 0.01
        } $script:TestVideo

        $expectedFrameCount = [int][Math]::Floor(8000 * $expectedDuration / 80)

        $activity.Frames.Count | Should -BeGreaterThan 0
        ([Math]::Abs($activity.Frames.Count - $expectedFrameCount) -le 2) | Should -Be $true

    }

    It 'Generates strictly increasing timestamps' {

        $activity = & $script:Module {
            param($path)
            Get-PCXAudioActivity -Path $path -FrameDuration 0.01
        } $script:TestVideo

        $invalidTimestamps = [System.Collections.Generic.List[object]]::new()
        for ($i = 1; $i -lt $activity.Frames.Count; $i++) {
            if ($activity.Frames[$i].Time -le $activity.Frames[$i - 1].Time) {
                $invalidTimestamps.Add($activity.Frames[$i])
            }
        }

        $invalidTimestamps.Count | Should -Be 0

    }

    It 'Computes numeric, non-negative frame energy values' {

        $activity = & $script:Module {
            param($path)
            Get-PCXAudioActivity -Path $path -FrameDuration 0.01
        } $script:TestVideo

        $invalidEnergyFrames = [System.Collections.Generic.List[object]]::new()
        foreach ($frame in $activity.Frames) {
            if ($frame.Energy -isnot [double] -or $frame.Energy -lt 0.0) {
                $invalidEnergyFrames.Add($frame)
            }
        }

        $invalidEnergyFrames.Count | Should -Be 0

    }

    It 'Supports flat extensibility without breaking property access' {

        $activity = & $script:Module {
            param($path)
            Get-PCXAudioActivity -Path $path -FrameDuration 0.05
        } $script:TestVideo

        $firstFrame = $activity.Frames[0]

        $firstFrame.Time | Should -Be 0.0
        $firstFrame.Energy | Should -BeOfType [double]
        $firstFrame.PSObject.Properties.Name | Should -Contain 'Time'
        $firstFrame.PSObject.Properties.Name | Should -Contain 'Energy'

    }

    It 'Throws appropriate exception for non-existent file' {

        {
            & $script:Module {
                Get-PCXAudioActivity -Path 'C:\NonExistentFile.mp4'
            }
        } | Should -Throw

    }

    It 'Throws appropriate exception when FrameDuration is invalid' {

        {
            & $script:Module {
                param($path)
                Get-PCXAudioActivity -Path $path -FrameDuration 0.0
            } $script:TestVideo
        } | Should -Throw

    }

}
