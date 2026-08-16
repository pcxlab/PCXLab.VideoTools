Describe 'ConvertTo-PCXConcatFilter' {

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

    It 'Generates audio and video concat filter graph when HasAudio is True (default)' {
        $module = Get-Module PCXLab.VideoTools
        $filter = & $module { param($s) $s | ConvertTo-PCXConcatFilter } $script:Segments
        $filter | Should -Match '\[0:v\]trim=start=0:end=5,setpts=PTS-STARTPTS\[v0\];'
        $filter | Should -Match '\[0:a\]atrim=start=0:end=5,asetpts=PTS-STARTPTS\[a0\];'
        $filter | Should -Match '\[v0\]\[a0\]\[v1\]\[a1\]'
        $filter | Should -Match 'concat=n=2:v=1:a=1\[outv\]\[outa\]'
    }

    It 'Generates video-only concat filter graph when HasAudio is False' {
        $module = Get-Module PCXLab.VideoTools
        $filter = & $module { param($s) $s | ConvertTo-PCXConcatFilter -HasAudio:$false } $script:Segments
        $filter | Should -Match '\[0:v\]trim=start=0:end=5,setpts=PTS-STARTPTS\[v0\];'
        $filter | Should -Not -Match 'atrim'
        $filter | Should -Match '\[v0\]\[v1\]'
        $filter | Should -Not -Match '\[a0\]'
        $filter | Should -Match 'concat=n=2:v=1:a=0\[outv\]'
        $filter | Should -Not -Match '\[outa\]'
    }

}
