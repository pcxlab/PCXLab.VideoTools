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

    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param(

        [Parameter(Mandatory)]
        [ValidateScript({
            Test-Path -LiteralPath $_ -PathType Leaf
        })]
        [string]$ReferencePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$SourcePaths,

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

    #
    # Build media sources
    #

    $allPaths = @($ReferencePath) + @($SourcePaths)

    $MediaSources = $allPaths |
        New-PCXMediaSource

    $ReferenceSource = $MediaSources |
        Where-Object { $_.Path -eq $ReferencePath } |
        Select-Object -First 1

    #
    # Resolve or create recording session
    #

    $Session = $MediaSources |
        Get-PCXRecordingSession `
            -ReferenceSourceId $ReferenceSource.Id `
            -CachePath $RecordingSessionCachePath

    #
    # Resolve or create reference analysis
    #

    $ReferenceAnalysis = Get-PCXVideoAnalysis `
        -Path $ReferencePath `
        -NoiseFloor $NoiseFloor `
        -MinimumDuration $MinimumDuration `
        -CachePath $ReferenceCachePath

    #
    # Generate reference edit points
    #

    $ReferenceEditPoints = $ReferenceAnalysis |
        Find-PCXSilence |
        Get-PCXEditPoint

    #
    # Translate edit points to synchronized sources
    #

    $TranslatedEditPoints = $ReferenceEditPoints |
        Sync-PCXEditPoint `
            -RecordingSession $Session

    #
    # Combine reference and translated edit points
    #

    $AllEditPoints = @($ReferenceEditPoints) + @($TranslatedEditPoints)

    #
    # Render one output per source
    #

    $Groups = $AllEditPoints |
        Group-Object -Property SourcePath

    foreach ($Group in $Groups) {

        $SourcePath = $Group.Name

        $Segments = $Group.Group |
            Get-PCXVideoSegments

        if ($Segments.Count -eq 0) {
            continue
        }

        if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {

            $Segments |
                Edit-PCXVideoSegments

        }
        else {

            $OutputFileName = [System.IO.Path]::GetFileName($SourcePath)
            $OutputPath = Join-Path $OutputDirectory $OutputFileName

            $Segments |
                Edit-PCXVideoSegments `
                    -OutputPath $OutputPath

        }

    }

}
