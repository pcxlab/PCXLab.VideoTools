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

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.IO.FileInfo])]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [ValidateNotNull()]
        [object]$Segment,

        [Parameter()]
        [string]$OutputPath,

        [Parameter()]
        [switch]$Force

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

        if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {

            $OutputPath = Get-PCXArtifactPath `
                -SourcePath $SourcePath `
                -ArtifactType EditedVideo `
                -OutputPath $OutputPath

        }
        else {

            $OutputPath = Get-PCXArtifactPath `
                -SourcePath $SourcePath `
                -ArtifactType EditedVideo

        }

        if (-not (Test-PCXShouldGenerateArtifact -Path $OutputPath -Force:$Force)) {
            return (Get-Item -LiteralPath $OutputPath)
        }

        #
        # Read source audio information & presence
        #

        $AudioInfo = Get-PCXAudioInformation -Path $SourcePath
        $HasAudio = ($null -ne $AudioInfo -and $AudioInfo.HasAudio)

        #
        # Build timeline filter graph
        #

        $FilterGraph = $Segments |
        ConvertTo-PCXConcatFilter `
            -InputIndex 0 `
            -HasAudio:$HasAudio

        #
        # Read audio filter settings
        #

        if ($HasAudio) {

            $AudioSettings = [PSCustomObject]@{
                Normalize      = Get-PCXSetting `
                    -Name 'Audio.Normalize' `
                    -DefaultValue $false

                Compression    = Get-PCXSetting `
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

        }

        #
        # Read source audio sample rate
        #

        $SampleRate = if ($HasAudio -and $AudioInfo.SampleRate) {
            $AudioInfo.SampleRate
        }
        else {
            0
        }

        #
        # Create editing job
        #

        $Job = New-PCXEditJobObject `
            -SourcePath $SourcePath `
            -OutputPath $OutputPath `
            -FilterGraph $FilterGraph `
            -SampleRate $SampleRate `
            -HasAudio:$HasAudio

        #
        # Execute job
        #

        if ($PSCmdlet.ShouldProcess($OutputPath, 'Render edited video')) {

            Invoke-PCXFFmpegEdit `
                -EditJob $Job

        }

    }

}
