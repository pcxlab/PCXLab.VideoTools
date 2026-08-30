function Search-PCXAudioCorrelation {

    <#
    .SYNOPSIS
        Searches audio correlation between two audio activity timelines.

    .DESCRIPTION
        Determines the optimal temporal offset between a reference timeline and a
        comparison timeline produced by Get-PCXAudioActivity using normalized
        cross-correlation over frame activity measurements.

        In addition to the best-fit offset and its Pearson correlation coefficient,
        the function returns:

        - SecondPeakCorrelation: the highest PCC found at any lag position that is
          separated from the primary peak by at least PeakExclusionWindow seconds,
          making it a genuinely independent competing alignment candidate. Returns
          $null when the search range contains no lag outside the exclusion zone.

        - OverlapFraction: the ratio of FramesCompared to the length of the shorter
          timeline, expressing what fraction of the maximum achievable overlap was
          used at the best alignment. Range [0, 1].

        Confidence is not computed here; it is the responsibility of
        Measure-PCXCorrelationConfidence, which accepts this result object.

    .PARAMETER ReferenceTimeline
        Reference audio activity timeline object.

    .PARAMETER ComparisonTimeline
        Comparison audio activity timeline object.

    .PARAMETER SearchWindow
        Maximum search window range in seconds around zero lag. If omitted,
        searches full overlapping timeline duration.

    .PARAMETER StepDuration
        Step duration in seconds between evaluated lag positions. Defaults to 1 frame step.

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Internal helper for Stage 2A audio activity correlation.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$ReferenceTimeline,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$ComparisonTimeline,

        [Parameter()]
        [ValidateRange(0, 3600)]
        [Nullable[double]]$SearchWindow,

        [Parameter()]
        [ValidateRange(0.001, 60.0)]
        [Nullable[double]]$StepDuration

    )

    if ($null -eq $ReferenceTimeline.Frames -or $ReferenceTimeline.Frames.Count -eq 0) {
        throw 'ReferenceTimeline must contain at least one frame.'
    }

    if ($null -eq $ComparisonTimeline.Frames -or $ComparisonTimeline.Frames.Count -eq 0) {
        throw 'ComparisonTimeline must contain at least one frame.'
    }

    $refFrameDuration = [double]$ReferenceTimeline.FrameDuration
    $compFrameDuration = [double]$ComparisonTimeline.FrameDuration

    if ([Math]::Abs($refFrameDuration - $compFrameDuration) -ge 1e-6) {
        throw 'Reference and comparison timelines must have matching FrameDuration values.'
    }

    $frameDuration = $refFrameDuration

    Write-Verbose "Correlating audio activity timelines (FrameDuration: ${frameDuration}s)."

    [double[]]$refSignal = @(Get-PCXTimelineFeatureVector -Timeline $ReferenceTimeline -FeatureName 'Energy')
    [double[]]$compSignal = @(Get-PCXTimelineFeatureVector -Timeline $ComparisonTimeline -FeatureName 'Energy')

    $stepFrames = 1
    if ($null -ne $StepDuration -and $StepDuration -gt 0) {
        $stepFrames = [int][Math]::Max(1, [Math]::Round($StepDuration / $frameDuration))
    }

    $minLag = - ($compSignal.Length - 1)
    $maxLag = $refSignal.Length - 1

    $effectiveSearchWindow = $null
    if ($null -ne $SearchWindow) {
        $effectiveSearchWindow = [double]$SearchWindow
        $windowLag = [int][Math]::Ceiling($SearchWindow / $frameDuration)
        $minLag = [Math]::Max($minLag, - $windowLag)
        $maxLag = [Math]::Min($maxLag, $windowLag)
    }
    else {
        $effectiveSearchWindow = [Math]::Round([Math]::Max($refSignal.Length, $compSignal.Length) * $frameDuration, 6)
    }

    if ($minLag -gt $maxLag) {
        throw 'SearchWindow bounds resulted in an invalid lag range.'
    }

    if (-not ([System.Management.Automation.PSTypeName]'PCXLab.VideoTools.Private.AudioCorrelationEngine').Type) {
        $csPath = Join-Path $PSScriptRoot 'AudioCorrelationEngine.cs'
        Add-Type -Path $csPath
    }

    $engineResult = [PCXLab.VideoTools.Private.AudioCorrelationEngine]::Search(
        $refSignal,
        $compSignal,
        $minLag,
        $maxLag,
        $stepFrames,
        $frameDuration,
        1.0
    )

    $bestOffset = $engineResult.BestOffset
    $bestCorrelation = $engineResult.Correlation
    $bestLag = $engineResult.BestLag
    $bestOverlap = $engineResult.FramesCompared
    $secondPeakCorrelation = $engineResult.SecondPeakCorrelation
    $overlapFraction = $engineResult.OverlapFraction

    Write-Verbose "Best timeline alignment: offset ${bestOffset}s (lag $bestLag frames, correlation $bestCorrelation)."

    return [PSCustomObject]@{
        BestOffset            = $bestOffset
        Correlation           = $bestCorrelation
        Confidence            = $null
        FramesCompared        = $bestOverlap
        SearchWindow          = $effectiveSearchWindow
        SecondPeakCorrelation = $secondPeakCorrelation
        OverlapFraction       = $overlapFraction
    }

}
