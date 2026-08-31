function New-PCXSilenceObject {

    <#
    .SYNOPSIS
        Creates a PCXLab.Silence object.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [TimeSpan]$Start,

        [Parameter(Mandatory)]
        [TimeSpan]$End,

        [Parameter(Mandatory)]
        [double]$DurationSeconds,

        [Parameter(Mandatory)]
        [string]$SourcePath

    )

    $editPolicy = Get-PCXEditPolicy

    $classification =
    if ($DurationSeconds -ge $editPolicy.RecordingBreakThreshold.TotalSeconds) {
        'RecordingBreak'
    }
    elseif ($DurationSeconds -ge $editPolicy.EditCandidateThreshold.TotalSeconds) {
        'EditCandidate'
    }
    else {
        'ShortPause'
    }

    [PSCustomObject]@{

        PSTypeName      = 'PCXLab.Silence'

        EventType       = 'Silence'

        # Source
        SourcePath      = $SourcePath
        Source          = [System.IO.Path]::GetFileName($SourcePath)

        # Time
        Start           = $Start
        End             = $End
        Duration        = [TimeSpan]::FromSeconds($DurationSeconds)

        # Numeric
        StartSeconds    = [Math]::Round($Start.TotalSeconds, 3)
        EndSeconds      = [Math]::Round($End.TotalSeconds, 3)
        DurationSeconds = [Math]::Round($DurationSeconds, 3)

        # Classification
        Classification  = $classification
    }

}
