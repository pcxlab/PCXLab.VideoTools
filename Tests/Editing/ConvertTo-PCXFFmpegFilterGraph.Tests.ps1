Describe 'ConvertTo-PCXFFmpegFilterGraph' {

    BeforeAll {
        . "$PSScriptRoot\..\TestHelper.ps1"
        $module = Get-Module PCXLab.VideoTools

        $script:Segment1 = & $module {
            New-PCXVideoSegmentObject -SourcePath 'C:\Video.mp4' -Start ([TimeSpan]::FromSeconds(0)) -End ([TimeSpan]::FromSeconds(5)) -Action 'Keep'
        }
        $script:Segment2 = & $module {
            New-PCXVideoSegmentObject -SourcePath 'C:\Video.mp4' -Start ([TimeSpan]::FromSeconds(10)) -End ([TimeSpan]::FromSeconds(15)) -Action 'Keep'
        }
        $script:Segments = @($script:Segment1, $script:Segment2)
    }

    It 'Generates standard audio and video concat filter graph when no audio settings are supplied' {
        $module = Get-Module PCXLab.VideoTools
        $filter = & $module { param($s) $s | ConvertTo-PCXFFmpegFilterGraph } $script:Segments
        $filter | Should -Match '\[0:v\]trim=start=0:end=5,setpts=PTS-STARTPTS\[v0\];'
        $filter | Should -Match '\[0:a\]atrim=start=0:end=5,asetpts=PTS-STARTPTS\[a0\];'
        $filter | Should -Match 'concat=n=2:v=1:a=1\[outv\]\[outa\]'
        $filter | Should -Not -Match '\[outa_pre\]'
    }

    It 'Generates video-only concat filter graph when HasAudio is False' {
        $module = Get-Module PCXLab.VideoTools
        $filter = & $module { param($s) $s | ConvertTo-PCXFFmpegFilterGraph -HasAudio:$false } $script:Segments
        $filter | Should -Match '\[0:v\]trim=start=0:end=5,setpts=PTS-STARTPTS\[v0\];'
        $filter | Should -Not -Match 'atrim'
        $filter | Should -Match 'concat=n=2:v=1:a=0\[outv\]'
        $filter | Should -Not -Match '\[outa\]'
    }

    It 'Merges audio post-processing filters and performs pad rewiring when AudioSettings are provided' {
        $module = Get-Module PCXLab.VideoTools
        $audioSettings = [PSCustomObject]@{
            Normalize      = $true
            Compression    = $true
            RepairChannels = $true
        }

        $filter = & $module {
            param($s, $settings)
            $s | ConvertTo-PCXFFmpegFilterGraph -AudioSettings $settings
        } $script:Segments $audioSettings

        $filter | Should -Match 'concat=n=2:v=1:a=1\[outv\]\[outa_pre\]'
        $filter | Should -Match ';\[outa_pre\]loudnorm,acompressor,pan=stereo\|c0=c0\|c1=c0\[outa\]'
    }

    It 'Leaves concat filter graph untouched when all AudioSettings are False' {
        $module = Get-Module PCXLab.VideoTools
        $audioSettings = [PSCustomObject]@{
            Normalize      = $false
            Compression    = $false
            RepairChannels = $false
        }

        $filter = & $module {
            param($s, $settings)
            $s | ConvertTo-PCXFFmpegFilterGraph -AudioSettings $settings
        } $script:Segments $audioSettings

        $filter | Should -Match 'concat=n=2:v=1:a=1\[outv\]\[outa\]'
        $filter | Should -Not -Match '\[outa_pre\]'
    }

    It 'Throws when non-VideoSegment objects are passed' {
        $module = Get-Module PCXLab.VideoTools
        {
            & $module {
                ConvertTo-PCXFFmpegFilterGraph -Segment ([PSCustomObject]@{ Invalid = 'Object' })
            }
        } | Should -Throw
    }

}
