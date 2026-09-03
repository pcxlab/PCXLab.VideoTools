function Invoke-PCXSynchronizedEditing {

    <#
    .SYNOPSIS
        Synchronizes edit decisions from a reference recording and applies
        them to every synchronized source.

    .DESCRIPTION
        Public entry point for the synchronized editing workflow.

        This command analyzes a reference recording, synchronizes the
        resulting edit decisions across every related recording, and renders
        synchronized edited outputs.

        This command supersedes Edit-PCXRecordingSession.

    .PARAMETER ReferencePath
        Path to the reference recording.

    .PARAMETER SourcePaths
        Paths to the synchronized recordings.

    .EXAMPLE
        Invoke-PCXSynchronizedEditing `
            -ReferencePath "Reference.mp4" `
            -SourcePaths @(
                "CameraA.mp4",
                "CameraB.mp4"
            )

    .OUTPUTS
        System.IO.FileInfo
    #>

    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param(

        [Parameter(
            Mandatory,
            ParameterSetName = 'Path'
        )]
        [string]$ReferencePath,

        [Parameter(
            Mandatory,
            ParameterSetName = 'Path'
        )]
        [string[]]$SourcePaths,

        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ParameterSetName = 'MediaSource'
        )]
        [object]$MediaSource,

        [Parameter(ParameterSetName = 'MediaSource')]
        [string]$ReferenceSourceId,

        [string]$OutputDirectory,

        [double]$NoiseFloor,

        [double]$MinimumDuration,

        [string]$RecordingSessionCachePath,

        [string]$ReferenceCachePath
    )

    process {

        Invoke-PCXSynchronizedEditingOrchestrator @PSBoundParameters

    }
}