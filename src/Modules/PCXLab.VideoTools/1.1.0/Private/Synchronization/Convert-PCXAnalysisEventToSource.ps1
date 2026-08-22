function Convert-PCXAnalysisEventToSource {

    <#
    .SYNOPSIS
        Translates analysis events to a target source timeline based on relative offset.

    .DESCRIPTION
        Converts temporal analysis events (Silence, BlackFrame, or any event conforming
        to the PCXLab analysis event contract) from a reference source timeline into
        the target source's local timeline by adjusting timestamps according to the
        source offset, clamping boundaries at zero, and recalculating durations.

    .PARAMETER Event
        One or more analysis event objects to translate. Must satisfy Test-PCXAnalysisEvent.

    .PARAMETER SourceOffset
        A PCXLab.SourceOffset object containing SourcePath and OffsetSeconds.

    .PARAMETER SourcePath
        Target source file path when specifying explicit offset parameters.

    .PARAMETER OffsetSeconds
        Offset in seconds of the target source relative to the reference source.

    .OUTPUTS
        PSCustomObject conforming to the PCXLab analysis event contract.
    #>

    [CmdletBinding(DefaultParameterSetName = 'BySourceOffset')]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [ValidateNotNull()]
        [object]$Event,

        [Parameter(
            Mandatory,
            ParameterSetName = 'BySourceOffset'
        )]
        [ValidateNotNull()]
        [object]$SourceOffset,

        [Parameter(
            Mandatory,
            ParameterSetName = 'ByExplicitOffset'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,

        [Parameter(
            Mandatory,
            ParameterSetName = 'ByExplicitOffset'
        )]
        [double]$OffsetSeconds

    )

    begin {

        if ($PSCmdlet.ParameterSetName -eq 'BySourceOffset') {
            $resolvedSourcePath    = $SourceOffset.SourcePath
            $resolvedOffsetSeconds = $SourceOffset.OffsetSeconds
        }
        else {
            $resolvedSourcePath    = $SourcePath
            $resolvedOffsetSeconds = $OffsetSeconds
        }

    }

    process {

        foreach ($currentEvent in @($Event)) {

            if (-not (Test-PCXAnalysisEvent -InputObject $currentEvent)) {
                throw "Input object must conform to the PCXLab analysis event contract."
            }

            $startSeconds = $currentEvent.Start.TotalSeconds - $resolvedOffsetSeconds
            $endSeconds   = $currentEvent.End.TotalSeconds - $resolvedOffsetSeconds

            # If the event ended before or at the start of the target media, it does not exist on this timeline
            if ($endSeconds -le 0) {
                continue
            }

            # Clamp start to 0 if the event began before target media started
            if ($startSeconds -lt 0) {
                $startSeconds = 0
            }

            $durationSeconds = $endSeconds - $startSeconds

            if ($durationSeconds -le 0) {
                continue
            }

            $newStart    = [TimeSpan]::FromSeconds($startSeconds)
            $newEnd      = [TimeSpan]::FromSeconds($endSeconds)
            $newDuration = [TimeSpan]::FromSeconds($durationSeconds)

            $translated = [PSCustomObject]@{}

            # Preserve non-contract properties from original event
            foreach ($prop in $currentEvent.PSObject.Properties) {
                if ($prop.Name -notin @('Start', 'End', 'Duration', 'StartSeconds', 'EndSeconds', 'DurationSeconds', 'SourcePath', 'Source')) {
                    $translated | Add-Member -NotePropertyName $prop.Name -NotePropertyValue $prop.Value
                }
            }

            # Standardized contract properties
            $translated | Add-Member -NotePropertyName 'EventType' -NotePropertyValue $currentEvent.EventType -Force
            $translated | Add-Member -NotePropertyName 'SourcePath' -NotePropertyValue $resolvedSourcePath -Force
            $translated | Add-Member -NotePropertyName 'Source' -NotePropertyValue ([System.IO.Path]::GetFileName($resolvedSourcePath)) -Force
            $translated | Add-Member -NotePropertyName 'Start' -NotePropertyValue $newStart -Force
            $translated | Add-Member -NotePropertyName 'End' -NotePropertyValue $newEnd -Force
            $translated | Add-Member -NotePropertyName 'Duration' -NotePropertyValue $newDuration -Force
            $translated | Add-Member -NotePropertyName 'StartSeconds' -NotePropertyValue ([Math]::Round($startSeconds, 3)) -Force
            $translated | Add-Member -NotePropertyName 'EndSeconds' -NotePropertyValue ([Math]::Round($endSeconds, 3)) -Force
            $translated | Add-Member -NotePropertyName 'DurationSeconds' -NotePropertyValue ([Math]::Round($durationSeconds, 3)) -Force

            # If silence, update classification to match new duration
            if ($currentEvent.EventType -eq 'Silence') {
                $classification = if ($durationSeconds -ge 15) {
                    'RecordingBreak'
                }
                elseif ($durationSeconds -ge 5) {
                    'EditCandidate'
                }
                else {
                    'ShortPause'
                }
                $translated | Add-Member -NotePropertyName 'Classification' -NotePropertyValue $classification -Force
            }

            # Preserve PSTypeNames
            if ($currentEvent.PSTypeNames.Count -gt 0) {
                foreach ($typeName in $currentEvent.PSTypeNames) {
                    if ($typeName -notin $translated.PSTypeNames) {
                        $translated.PSTypeNames.Insert(0, $typeName)
                    }
                }
            }

            $translated

        }

    }

}
