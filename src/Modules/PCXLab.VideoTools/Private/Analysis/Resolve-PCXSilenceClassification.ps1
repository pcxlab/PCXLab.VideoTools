function Resolve-PCXSilenceClassification {

    <#
    .SYNOPSIS
        Classifies a silence interval based on its duration.

    .DESCRIPTION
        Evaluates a silence duration against thresholds defined in Get-PCXEditPolicy
        to determine its editing classification:
        - RecordingBreak (>= 15s)
        - EditCandidate  (>= 5s)
        - ShortPause     (< 5s)

    .PARAMETER DurationSeconds
        Duration of the silence region in seconds.

    .PARAMETER Duration
        TimeSpan duration of the silence region.

    .OUTPUTS
        System.String
    #>

    [CmdletBinding(DefaultParameterSetName = 'BySeconds')]
    [OutputType([string])]
    param(

        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'BySeconds'
        )]
        [ValidateRange(0, [double]::MaxValue)]
        [double]$DurationSeconds,

        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByTimeSpan'
        )]
        [TimeSpan]$Duration

    )

    process {

        $seconds = if ($PSCmdlet.ParameterSetName -eq 'ByTimeSpan') {
            $Duration.TotalSeconds
        }
        else {
            $DurationSeconds
        }

        $editPolicy = Get-PCXEditPolicy

        if ($seconds -ge $editPolicy.RecordingBreakThreshold.TotalSeconds) {
            'RecordingBreak'
        }
        elseif ($seconds -ge $editPolicy.EditCandidateThreshold.TotalSeconds) {
            'EditCandidate'
        }
        else {
            'ShortPause'
        }

    }

}
