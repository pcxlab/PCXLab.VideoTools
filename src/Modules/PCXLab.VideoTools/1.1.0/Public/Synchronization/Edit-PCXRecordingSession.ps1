function Edit-PCXRecordingSession {

    <#
    .SYNOPSIS
        Edits every synchronized recording in a session using the same edit decisions.

    .DESCRIPTION
        Thin orchestration command that connects the existing analysis,
        synchronization, and editing commands into a single workflow.

        It analyzes the reference recording, generates edit decisions from silence,
        translates those decisions to every synchronized source, and renders one
        edited video per source.

    .PARAMETER ReferencePath
        Path to the reference media file.

    .PARAMETER SourcePaths
        Paths to the other media files in the recording session.

    .PARAMETER OutputDirectory
        Optional directory for rendered outputs. If omitted, outputs are written
        beside each source using the default naming of Edit-PCXVideoSegments.

    .PARAMETER NoiseFloor
        Audio level at or below which audio is considered silence, in decibels.

    .PARAMETER MinimumDuration
        Minimum silence duration, in seconds.

    .PARAMETER RecordingSessionCachePath
        Optional path to the RecordingSession.json cache file.

    .PARAMETER ReferenceCachePath
        Optional path to the reference Analysis.json cache file.

    .EXAMPLE
        Edit-PCXRecordingSession `
            -ReferencePath 'C:\Recordings\Bandicam.mp4' `
            -SourcePaths @('C:\Recordings\Nokia.mp4', 'C:\Recordings\Webcam.mp4')

    .OUTPUTS
        System.IO.FileInfo
    #>
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([System.IO.FileInfo])]
    param(

        [Parameter(
            Mandatory,
            ParameterSetName = 'Path'
        )]
        [ValidateScript({
                Test-Path -LiteralPath $_ -PathType Leaf
            })]
        [string]$ReferencePath,

        [Parameter(
            Mandatory,
            ParameterSetName = 'Path'
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$SourcePaths,

        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ParameterSetName = 'MediaSource'
        )]
        [ValidateNotNull()]
        [object]$MediaSource,

        [Parameter(ParameterSetName = 'MediaSource')]
        [ValidateNotNullOrEmpty()]
        [string]$ReferenceSourceId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$OutputDirectory,

        [Parameter()]
        [double]$NoiseFloor = (
            Get-PCXSetting `
                -Name 'Analysis.SilenceThreshold' `
                -DefaultValue -35
        ),

        [Parameter()]
        [double]$MinimumDuration = (
            Get-PCXSetting `
                -Name 'Analysis.MinimumSilenceDuration' `
                -DefaultValue 1
        ),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$RecordingSessionCachePath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ReferenceCachePath

    )

    begin {

        $MediaSourceList = [System.Collections.Generic.List[object]]::new()

    }

    process {

        if ($PSCmdlet.ParameterSetName -eq 'MediaSource') {

            if ($MediaSource.PSTypeNames -notcontains 'PCXLab.MediaSource') {
                throw 'MediaSource must be a PCXLab.MediaSource object.'
            }

            $MediaSourceList.Add($MediaSource)

        }

    }

    end {

        #
        # Build or collect media sources
        #

        if ($PSCmdlet.ParameterSetName -eq 'Path') {

            $MediaSourceList = Build-PCXMediaSourcesFromPaths `
                -ReferencePath $ReferencePath `
                -SourcePaths $SourcePaths

        }

        if ($MediaSourceList.Count -lt 2) {
            throw 'At least two media sources are required for synchronization.'
        }

        $ReferenceSource = $MediaSourceList[0]

        if (-not [string]::IsNullOrWhiteSpace($ReferenceSourceId)) {

            $resolved = @($MediaSourceList | Where-Object { $_.Id -eq $ReferenceSourceId })

            if ($resolved.Count -eq 0) {
                throw "Reference source '$ReferenceSourceId' was not found."
            }

            if ($resolved.Count -gt 1) {
                throw "Multiple sources were found with Id '$ReferenceSourceId'."
            }

            $ReferenceSource = $resolved[0]

        }

    #
    # Resolve or create recording session
    #

        $RecordingSessionArguments = @{
            ReferenceSourceId = $ReferenceSource.Id
        }

        if (-not [string]::IsNullOrWhiteSpace($RecordingSessionCachePath)) {
            $RecordingSessionArguments.CachePath = $RecordingSessionCachePath
        }

        $Session = $MediaSourceList |
        Get-PCXRecordingSession @RecordingSessionArguments

    #
    # Resolve or create reference analysis
    #

        $AnalysisArguments = @{
            Path            = $ReferenceSource.Path
            NoiseFloor      = $NoiseFloor
            MinimumDuration = $MinimumDuration
        }

        if (-not [string]::IsNullOrWhiteSpace($ReferenceCachePath)) {
            $AnalysisArguments.CachePath = $ReferenceCachePath
        }

        $ReferenceAnalysis = Get-PCXVideoAnalysis @AnalysisArguments

    #
    # Generate reference edit points
    #

        $ReferenceEditPoints = $ReferenceAnalysis |
        Find-PCXSilence |
        Get-PCXEditPoint

        Write-Host ""
        Write-Host "===================================" -ForegroundColor Cyan
        Write-Host "Reference Edit Points : $(@($ReferenceEditPoints).Count)" -ForegroundColor Cyan

    #
    # Translate edit points to synchronized sources
    #

        $TranslatedEditPoints = $ReferenceEditPoints |
        Sync-PCXEditPoint `
            -RecordingSession $Session

        Write-Host "Translated Edit Points: $(@($TranslatedEditPoints).Count)" -ForegroundColor Cyan

    #
    # Combine reference and translated edit points
    #

        $AllEditPoints = @($ReferenceEditPoints) + @($TranslatedEditPoints)

        Write-Host "Total Edit Points     : $(@($AllEditPoints).Count)" -ForegroundColor Cyan

    #
    # Group by source
    #

        $Groups = $AllEditPoints |
        Group-Object -Property SourcePath

        Write-Host "Source Groups         : $(@($Groups).Count)" -ForegroundColor Cyan
        Write-Host "===================================" -ForegroundColor Cyan

    #
    # Render one output per source
    #

        foreach ($Group in $Groups) {

            $SourcePath = $Group.Name

            Write-Host ""
            Write-Host "-----------------------------------" -ForegroundColor Yellow
            Write-Host "Processing Source :" -ForegroundColor Yellow
            Write-Host "    $SourcePath"
            Write-Host "Edit Points       : $(@($Group.Group).Count)" -ForegroundColor Yellow

            $Segments = $Group.Group |
            Get-PCXVideoSegments

            Write-Host "Video Segments    : $(@($Segments).Count)" -ForegroundColor Green

            if ($Segments.Count -eq 0) {

                Write-Host "Skipping source because no segments were generated." -ForegroundColor Red

                continue

            }

            #
            # Export reusable timeline artifacts before rendering.
            # VideoSegments.json is the canonical editing checkpoint.
            # Editor-specific artifacts are derived from it.
            #

            $null = $Segments | Export-PCXVideoSegment
            $null = $Segments | Export-PCXPremiereMarkers
            $null = $Segments | Export-PCXPremiereEditPoints

            if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {

                Write-Host "Rendering using default output path..." -ForegroundColor Green

                $Segments |
                Edit-PCXVideoSegments

            }
            else {

                $OutputPath = Get-PCXOutputPath `
                    -SourcePath $SourcePath `
                    -OutputDirectory $OutputDirectory

                $Segments |
                Edit-PCXVideoSegments `
                    -OutputPath $OutputPath

            }

        }

    }

}
