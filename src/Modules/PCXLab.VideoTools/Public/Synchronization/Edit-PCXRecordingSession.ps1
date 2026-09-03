function Edit-PCXRecordingSession {

    <#
    .SYNOPSIS
        Edits every synchronized recording in a session using the same edit decisions.

    .NOTES

        DEPRECATED

        Edit-PCXRecordingSession is deprecated and will be removed
        in a future major release.

        Use Invoke-PCXSynchronizedEditing instead.

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
            (Get-PCXAnalysisPolicy).Silence.NoiseFloor
        ),

        [Parameter()]
        [double]$MinimumDuration = (
            (Get-PCXAnalysisPolicy).Silence.MinimumDuration
        ),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$RecordingSessionCachePath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ReferenceCachePath

    )

    begin {

        Write-Warning "Edit-PCXRecordingSession is deprecated and will be removed in a future major release. Please use Invoke-PCXSynchronizedEditing instead."

    }

    process {

        Invoke-PCXSynchronizedEditingOrchestrator @PSBoundParameters

    }

}
