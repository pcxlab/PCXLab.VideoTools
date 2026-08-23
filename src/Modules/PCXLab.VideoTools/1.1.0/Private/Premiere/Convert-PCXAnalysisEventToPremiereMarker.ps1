function Convert-PCXAnalysisEventToPremiereMarker {

    <#
    .SYNOPSIS
        Converts an analysis event into a normalized Premiere marker object.

    .DESCRIPTION
        Transforms raw analysis events (such as PCXLab.Silence, PCXLab.BlackFrame,
        or any object conforming to Test-PCXAnalysisEvent) into a PCXLab.PremiereMarker.

        This function represents pure factual telemetry visualization with zero
        editing heuristics or policies applied.

    .PARAMETER Event
        The analysis event object to convert.

    .OUTPUTS
        PCXLab.PremiereMarker
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Event

    )

    $invariantCulture = [System.Globalization.CultureInfo]::InvariantCulture

    $startSeconds = if ($null -ne $Event.StartSeconds) {
        [double]$Event.StartSeconds
    }
    elseif ($Event.Start -is [TimeSpan]) {
        $Event.Start.TotalSeconds
    }
    else {
        0.0
    }

    $endSeconds = if ($null -ne $Event.EndSeconds) {
        [double]$Event.EndSeconds
    }
    elseif ($Event.End -is [TimeSpan]) {
        $Event.End.TotalSeconds
    }
    else {
        $startSeconds
    }

    $durationSeconds = if ($null -ne $Event.DurationSeconds) {
        [double]$Event.DurationSeconds
    }
    elseif ($Event.Duration -is [TimeSpan]) {
        $Event.Duration.TotalSeconds
    }
    else {
        ($endSeconds - $startSeconds)
    }

    $durationStr = $durationSeconds.ToString('0.###', $invariantCulture)

    #
    # Factual mapping based on EventType / PSTypeName
    #
    if ($Event.PSTypeNames -contains 'PCXLab.Silence' -or $Event.EventType -eq 'Silence') {
        $classification = if (-not [string]::IsNullOrWhiteSpace($Event.Classification)) {
            $Event.Classification
        }
        else {
            'Unclassified'
        }

        $name = "Silence - $classification"
        $comments = "Detected silence: $durationStr seconds. Classification: $classification."
    }
    elseif ($Event.PSTypeNames -contains 'PCXLab.BlackFrame' -or $Event.EventType -eq 'BlackFrame') {
        $name = "BlackFrame"
        $comments = "Detected black frames: $durationStr seconds."
    }
    else {
        $eventType = if (-not [string]::IsNullOrWhiteSpace($Event.EventType)) {
            $Event.EventType
        }
        else {
            'AnalysisEvent'
        }

        $name = $eventType
        $comments = "Detected $eventType`: $durationStr seconds."
    }

    New-PCXPremiereMarkerObject `
        -StartSeconds $startSeconds `
        -EndSeconds $endSeconds `
        -Name $name `
        -Comments $comments

}
