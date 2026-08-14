function Edit-PCXVideoSegments {

    <#
    .SYNOPSIS
        Renders edited video from video segments.

    .DESCRIPTION
        Accepts PCXLab.VideoSegment objects and creates a new edited video
        using FFmpeg. This command extracts the rendering logic from
        Remove-PCXSilence so it can be reused with any edit source.

    .PARAMETER Segment
        PCXLab.VideoSegment objects received from the pipeline.

    .PARAMETER OutputPath
        Destination media file. If omitted, a default path is generated
        beside the source media file.

    .OUTPUTS
        System.IO.FileInfo
    #>

    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [ValidateNotNull()]
        [object]$Segment,

        [Parameter()]
        [string]$OutputPath

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

        $uniqueSourcePaths = @($Segments.SourcePath | Sort-Object -Unique)

        if ($uniqueSourcePaths.Count -gt 1) {
            throw "All video segments must belong to the same source. Found: $($uniqueSourcePaths -join ', ')."
        }

        $SourcePath = $Segments[0].SourcePath

        #
        # Resolve output path
        #

        if ([string]::IsNullOrWhiteSpace($OutputPath)) {

            $OutputPath = Get-PCXDefaultOutputPath `
                -SourcePath $SourcePath `
                -Suffix 'Edited' `
                -Extension '.mp4'

        }

        #
        # Build timeline filter graph
        #

        $FilterGraph = $Segments |
        ConvertTo-PCXConcatFilter `
            -InputIndex 0

        #
        # Read audio filter settings
        #

        $AudioSettings = [PSCustomObject]@{
            Normalize = Get-PCXSetting `
                -Name 'Audio.Normalize' `
                -DefaultValue $false

            Compression = Get-PCXSetting `
                -Name 'Audio.Compression' `
                -DefaultValue $false

            RepairChannels = Get-PCXSetting `
                -Name 'Audio.RepairChannels' `
                -DefaultValue $false
        }

        $AudioFilter = ConvertTo-PCXAudioFilter `
            -Settings $AudioSettings

        #
        # Merge audio filter into the filter graph
        #

        if (-not [string]::IsNullOrWhiteSpace($AudioFilter)) {

            $FilterGraph = $FilterGraph -replace '\[outa\]$', '[outa_pre]'

            $FilterGraph += ";[outa_pre]$AudioFilter[outa]"

        }

        #
        # Read source audio sample rate
        #

        $AudioInfo = Get-PCXAudioInformation -Path $SourcePath

        $SampleRate = if ($AudioInfo -and $AudioInfo.SampleRate) {
            $AudioInfo.SampleRate
        } else {
            0
        }

        #
        # Create editing job
        #

        $Job = New-PCXEditJobObject `
            -SourcePath $SourcePath `
            -OutputPath $OutputPath `
            -FilterGraph $FilterGraph `
            -SampleRate $SampleRate

        #
        # Execute job
        #

        Invoke-PCXFFmpegEdit `
            -EditJob $Job

    }

}
