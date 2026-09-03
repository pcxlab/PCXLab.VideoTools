function ConvertTo-PCXFFmpegFilterGraph {

    <#
    .SYNOPSIS
        Compiles a complete FFmpeg filter graph from video segments and audio settings.

    .DESCRIPTION
        Builds the full FFmpeg filter_complex graph string from PCXLab.VideoSegment
        objects. Assembles the video/audio trim and concat filter chains and, if
        audio settings are supplied and audio is present, appends the post-processing
        audio filters with appropriate pad rewiring.

        This function is a pure builder: it does not query configuration settings,
        maintaining full determinism and testability.

    .PARAMETER Segment
        Video segments received from the pipeline.

    .PARAMETER InputIndex
        Input stream index for FFmpeg (default 0).

    .PARAMETER HasAudio
        Indicates whether the source media has audio streams to process. Default is $true.

    .PARAMETER AudioSettings
        Optional settings object containing audio post-processing flags (Normalize,
        Compression, RepairChannels).

    .PARAMETER VideoSettings
        Optional settings object containing video post-processing flags (HorizontalFlip).
        If omitted, video settings are derived from the supplied video segments.

    .OUTPUTS
        System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [ValidateNotNull()]
        [object]$Segment,

        [Parameter()]
        [ValidateRange(0, 100)]
        [int]$InputIndex = 0,

        [Parameter()]
        [switch]$HasAudio = $true,

        [Parameter()]
        [object]$AudioSettings,

        [Parameter()]
        [object]$VideoSettings

    )

    begin {

        $Segments = [System.Collections.Generic.List[object]]::new()

    }

    process {

        if ($Segment.PSTypeNames -notcontains 'PCXLab.VideoSegment') {
            throw 'InputObject must be a PCXLab.VideoSegment object.'
        }

        $Segments.Add($Segment)

    }

    end {

        if ($Segments.Count -eq 0) {
            throw 'No video segments were supplied.'
        }

        #
        # Build base concat filter graph
        #

        $FilterGraph = $Segments |
        ConvertTo-PCXConcatFilter `
            -InputIndex $InputIndex `
            -HasAudio:$HasAudio

        #
        # Resolve video settings from parameter or segments
        #

        $effectiveVideoSettings = if ($null -ne $VideoSettings) {
            $VideoSettings
        }
        else {
            $hasFlip = $false
            foreach ($seg in $Segments) {
                if ($seg.HorizontalFlip -eq $true) {
                    $hasFlip = $true
                    break
                }
            }

            if ($hasFlip) {
                [PSCustomObject]@{
                    HorizontalFlip = $true
                }
            }
            else {
                $null
            }
        }

        #
        # Process and merge video filters if video settings are enabled
        #

        if ($null -ne $effectiveVideoSettings) {

            $VideoFilter = ConvertTo-PCXVideoFilter `
                -Settings $effectiveVideoSettings

            if (-not [string]::IsNullOrWhiteSpace($VideoFilter)) {

                $FilterGraph = $FilterGraph -replace '\[outv\]', '[outv_pre]'

                $FilterGraph += ";[outv_pre]$VideoFilter[outv]"

            }

        }

        #
        # Process and merge audio filters if audio is enabled
        #

        if ($HasAudio -and $null -ne $AudioSettings) {

            $AudioFilter = ConvertTo-PCXAudioFilter `
                -Settings $AudioSettings

            if (-not [string]::IsNullOrWhiteSpace($AudioFilter)) {

                $FilterGraph = $FilterGraph -replace '\[outa\]', '[outa_pre]'

                $FilterGraph += ";[outa_pre]$AudioFilter[outa]"

            }

        }

        return $FilterGraph

    }

}
