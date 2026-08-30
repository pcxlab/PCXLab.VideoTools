function Get-PCXSynchronizationOffset {

    <#
    .SYNOPSIS
        Calculates synchronization offset between two media recordings.

    .DESCRIPTION
        Orchestrates Stage 1 (audio timeline extraction via Get-PCXAudioActivity)
        and Stage 2A (timeline correlation search via Search-PCXAudioCorrelation)
        to determine the temporal offset of a comparison media recording relative to
        a reference recording.

    .PARAMETER ReferencePath
        Path to the reference media file.

    .PARAMETER ComparisonPath
        Path to the comparison media file.

    .PARAMETER SearchWindow
        Maximum search window range in seconds around zero lag. Default searches
        full overlapping duration.

    .PARAMETER StepDuration
        Step duration in seconds between evaluated lag positions.

    .PARAMETER FrameDuration
        Frame duration in seconds used for audio activity analysis. Default is 0.01 (10ms).

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Internal helper for Stage 2B synchronization orchestration.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]$ReferencePath,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]$ComparisonPath,

        [Parameter()]
        [ValidateRange(0, 3600)]
        [Nullable[double]]$SearchWindow,

        [Parameter()]
        [ValidateRange(0.001, 60.0)]
        [Nullable[double]]$StepDuration,

        [Parameter()]
        [ValidateRange(0.001, 10.0)]
        [double]$FrameDuration = 0.01

    )

    Write-Verbose "Calculating synchronization offset between '$ReferencePath' and '$ComparisonPath'."

    $refTimeline = Get-PCXAudioActivity -Path $ReferencePath -FrameDuration $FrameDuration
    $compTimeline = Get-PCXAudioActivity -Path $ComparisonPath -FrameDuration $FrameDuration

    $correlationArgs = @{
        ReferenceTimeline  = $refTimeline
        ComparisonTimeline = $compTimeline
    }

    if ($PSBoundParameters.ContainsKey('SearchWindow')) {
        $correlationArgs['SearchWindow'] = $SearchWindow
    }

    if ($PSBoundParameters.ContainsKey('StepDuration')) {
        $correlationArgs['StepDuration'] = $StepDuration
    }

    $correlationResult = Search-PCXAudioCorrelation @correlationArgs

    Write-Verbose "Synchronization offset determined: $($correlationResult.BestOffset)s (Correlation: $($correlationResult.Correlation))."

    return [PSCustomObject]@{
        ReferencePath     = $ReferencePath
        ComparisonPath    = $ComparisonPath
        Offset            = $correlationResult.BestOffset
        Correlation       = $correlationResult.Correlation
        Confidence        = $correlationResult.Confidence
        FrameRate         = $refTimeline.FrameRate
        Method            = 'AudioCorrelation'
        CorrelationResult = $correlationResult
    }

}
