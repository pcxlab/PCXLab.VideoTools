function New-PCXSynchronizationTimelineObject {

    <#
    .SYNOPSIS
        Creates a PCXLab.SynchronizationTimeline object.

    .DESCRIPTION
        Represents the resulting synchronized timeline built from a
        reference source and a set of relative source offsets.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ReferenceId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ReferencePath,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [TimeSpan]$ReferenceDuration,

        [Parameter()]
        [ValidateNotNull()]
        [object[]]$SourceOffsets = @(),

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [TimeSpan]$TotalDuration,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object[]]$Segments

    )

    [PSCustomObject]@{

        PSTypeName = 'PCXLab.SynchronizationTimeline'

        ReferenceId   = $ReferenceId
        ReferencePath = $ReferencePath

        ReferenceDuration = [Math]::Round(
            $ReferenceDuration.TotalSeconds,
            3
        )

        SourceOffsets = $SourceOffsets

        TotalDuration = $TotalDuration
        TotalDurationSeconds = [Math]::Round(
            $TotalDuration.TotalSeconds,
            3
        )

        Segments = $Segments

    }

}
