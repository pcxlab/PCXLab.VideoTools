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
        [switch]$HorizontalFlip,

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

        if ($HorizontalFlip) {
            foreach ($seg in $Segments) {
                $seg.HorizontalFlip = $true
            }
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

        #
        # 1. Companion Edited Timeline Artifacts — evaluated before rendering for failure recovery
        #
        try {

            $timelineMap = New-PCXTimelineMapObject -Segments $Segments

            $editedSegments = @(
                ConvertTo-PCXEditedSegments `
                    -VideoSegments @($Segments) `
                    -TimelineMap $timelineMap
            )

            # A. Edited Cuts (.jsx) — seam join points on the edited timeline
            $cutPoints = @(Get-PCXEditedCutPoints -TimelineMap $timelineMap)

            if ($cutPoints.Count -gt 0) {

                $editedCutsPath = Get-PCXArtifactPath `
                    -SourcePath $SourcePath `
                    -ArtifactType EditedPremiereEditPoint

                if (Test-PCXShouldGenerateArtifact -Path $editedCutsPath -Force:$Force) {

                    $cutScript = ConvertTo-PCXPremiereEditPointScript `
                        -CutPointsSeconds @($cutPoints)

                    Set-Content -LiteralPath $editedCutsPath -Value $cutScript -Encoding UTF8

                }

            }

            # B. Edited Markers (.jsx) — projected from in-memory pipeline data
            $inMemoryEvents = [System.Collections.Generic.List[object]]::new()
            foreach ($seg in $Segments) {
                if ($null -ne $seg.AnalysisEvents) {
                    foreach ($ev in @($seg.AnalysisEvents)) {
                        if ($null -ne $ev) {
                            $inMemoryEvents.Add($ev)
                        }
                    }
                }
            }

            $videoSegmentsPath = Get-PCXArtifactPath `
                -SourcePath $SourcePath `
                -ArtifactType VideoSegment

            $premiereMarkersPath = Get-PCXArtifactPath `
                -SourcePath $SourcePath `
                -ArtifactType PremiereMarker

            $premiereEditPointsPath = Get-PCXArtifactPath `
                -SourcePath $SourcePath `
                -ArtifactType PremiereEditPoint

            $sourceDirectory = [System.IO.Path]::GetDirectoryName($SourcePath)
            $sourceBaseName = [System.IO.Path]::GetFileNameWithoutExtension($SourcePath)
            $removeMarkersPath = Join-Path $sourceDirectory "$sourceBaseName-RemoveMarkers.jsx"
            $removeEditPointsPath = Join-Path $sourceDirectory "$sourceBaseName-RemoveEditPoints.jsx"

            $markersToProject = [System.Collections.Generic.List[object]]::new()

            # Include Keep segment markers
            foreach ($keepSeg in @($Segments | Where-Object Action -eq 'Keep')) {
                $markersToProject.Add((ConvertTo-PCXPremiereMarker -InputObject $keepSeg))
            }

            # Include any attached analysis events
            if ($inMemoryEvents.Count -gt 0) {
                foreach ($ev in $inMemoryEvents) {
                    $markersToProject.Add((ConvertTo-PCXPremiereMarker -InputObject $ev))
                }
            }

            if ($markersToProject.Count -gt 0) {

                $editedMarkers = @(
                    ConvertTo-PCXEditedTimelineMarker `
                        -Marker $markersToProject `
                        -TimelineMap $timelineMap
                )

                if ($editedMarkers.Count -gt 0) {

                    $editedMarkersPath = Get-PCXArtifactPath `
                        -SourcePath $SourcePath `
                        -ArtifactType EditedPremiereMarker

                    if (Test-PCXShouldGenerateArtifact -Path $editedMarkersPath -Force:$Force) {

                        $markerScript = ConvertTo-PCXPremiereMarkerScript `
                            -Marker $editedMarkers

                        Set-Content -LiteralPath $editedMarkersPath -Value $markerScript -Encoding UTF8

                    }

                }

            }

            # C. Edited Analysis (.json) — projected VideoAnalysis container checkpoint
            if ($inMemoryEvents.Count -gt 0) {

                $editedAnalysisPath = Get-PCXArtifactPath `
                    -SourcePath $SourcePath `
                    -ArtifactType EditedAnalysis

                if (Test-PCXShouldGenerateArtifact -Path $editedAnalysisPath -Force:$Force) {

                    $silenceEvents = @($inMemoryEvents | Where-Object EventType -eq 'Silence')
                    $blackFrameEvents = @($inMemoryEvents | Where-Object EventType -eq 'BlackFrame')

                    $syntheticAnalysis = New-PCXVideoAnalysisObject `
                        -SourcePath $SourcePath `
                        -Media ([PSCustomObject]@{ DurationSeconds = $timelineMap.OriginalDurationSeconds }) `
                        -Silence $silenceEvents `
                        -BlackFrames $blackFrameEvents

                    $projectedAnalysis = $syntheticAnalysis |
                        Convert-PCXVideoAnalysisToEdited `
                            -TimelineMap $timelineMap `
                            -EditedSourcePath $OutputPath

                    $null = $projectedAnalysis |
                        Export-PCXVideoAnalysis `
                            -Path $editedAnalysisPath `
                            -Force:$Force

                }
                else {

                }

            }

            if ($editedSegments.Count -gt 0) {
                $editedVideoSegmentsPath = Get-PCXArtifactPath `
                    -SourcePath $SourcePath `
                    -ArtifactType EditedVideoSegment

                $null = $editedSegments |
                    Export-PCXVideoSegment `
                        -Path $editedVideoSegmentsPath `
                        -Force:$Force

                $editedRemoveSegments = @($Segments | Where-Object Action -eq 'Remove')

                if ($editedRemoveSegments.Count -gt 0) {
                    $editedRemoveMarkersPath = Join-Path $sourceDirectory "$sourceBaseName-EditedRemoveMarkers.jsx"
                    $editedRemoveEditPointsPath = Join-Path $sourceDirectory "$sourceBaseName-EditedRemoveEditPoints.jsx"

                    $null = $editedRemoveSegments |
                        Export-PCXPremiereMarkers `
                            -Path $editedRemoveMarkersPath `
                            -Force:$Force

                    $null = $editedRemoveSegments |
                        Export-PCXPremiereEditPoints `
                            -Path $editedRemoveEditPointsPath `
                            -Force:$Force
                }
            }

            $null = $Segments |
                Export-PCXVideoSegment `
                    -Path $videoSegmentsPath `
                    -Force:$Force

            $null = $Segments |
                Export-PCXPremiereMarkers `
                    -Path $premiereMarkersPath `
                    -Force:$Force

            $null = $Segments |
                Export-PCXPremiereEditPoints `
                    -Path $premiereEditPointsPath `
                    -Force:$Force

            $removeSegments = @($Segments | Where-Object Action -eq 'Remove')

            $null = $removeSegments |
                Export-PCXPremiereMarkers `
                    -Path $removeMarkersPath `
                    -Force:$Force

            $null = $removeSegments |
                Export-PCXPremiereEditPoints `
                    -Path $removeEditPointsPath `
                    -Force:$Force

        }
        catch {
            Write-Warning "Failed to generate companion edited timeline artifacts: $($_.Exception.Message)"
        }

        #
        # 2. Render Edited Video via FFmpeg
        #
        if (Test-PCXShouldGenerateArtifact -Path $OutputPath -Force:$Force) {

            #
            # Read source audio information & presence
            #

            $AudioInfo = Get-PCXAudioInformation -Path $SourcePath
            $HasAudio = ($null -ne $AudioInfo -and $AudioInfo.HasAudio)

            #
            # Resolve audio filter settings
            #

            $AudioSettings = if ($HasAudio) {
                [PSCustomObject]@{
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
            }
            else {
                $null
            }

            #
            # Build timeline filter graph
            #

            $FilterGraph = $Segments |
            ConvertTo-PCXFFmpegFilterGraph `
                -InputIndex 0 `
                -HasAudio:$HasAudio `
                -AudioSettings $AudioSettings

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
            # Create FFmpeg render job
            #

            $Job = New-PCXFFmpegRenderJobObject `
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
                    -RenderJob $Job | Out-Null

            }

        }

        #
        # Return the edited video FileInfo object
        #
        if (Test-Path -LiteralPath $OutputPath) {
            return (Get-Item -LiteralPath $OutputPath)
        }

    }

}

