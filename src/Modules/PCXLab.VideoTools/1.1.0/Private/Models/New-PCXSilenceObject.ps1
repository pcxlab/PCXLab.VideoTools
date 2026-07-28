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
        [double]$DurationSeconds

    )

    $classification =
        if ($DurationSeconds -ge 15) {
            'RecordingBreak'
        }
        elseif ($DurationSeconds -ge 5) {
            'EditCandidate'
        }
        else {
            'ShortPause'
        }

    [PSCustomObject]@{

        PSTypeName = 'PCXLab.Silence'

        Start = $Start
        End = $End
        Duration = [TimeSpan]::FromSeconds($DurationSeconds)

        StartSeconds = [Math]::Round($Start.TotalSeconds, 3)
        EndSeconds = [Math]::Round($End.TotalSeconds, 3)
        DurationSeconds = [Math]::Round($DurationSeconds, 3)

        Classification = $classification
    }

}
