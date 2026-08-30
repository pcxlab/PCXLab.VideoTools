function Search-PCXAudioCorrelation {

    <#
    .SYNOPSIS
        Searches audio correlation between two audio activity timelines.

    .DESCRIPTION
        Determines the optimal temporal offset between a reference timeline and a
        comparison timeline produced by Get-PCXAudioActivity using normalized
        cross-correlation over frame activity measurements.

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

    $minLag = -($compSignal.Length - 1)
    $maxLag = $refSignal.Length - 1

    $effectiveSearchWindow = $null
    if ($null -ne $SearchWindow) {
        $effectiveSearchWindow = [double]$SearchWindow
        $windowLag = [int][Math]::Ceiling($SearchWindow / $frameDuration)
        $minLag = [Math]::Max($minLag, -$windowLag)
        $maxLag = [Math]::Min($maxLag, $windowLag)
    }
    else {
        $effectiveSearchWindow = [Math]::Round([Math]::Max($refSignal.Length, $compSignal.Length) * $frameDuration, 6)
    }

    if ($minLag -gt $maxLag) {
        throw 'SearchWindow bounds resulted in an invalid lag range.'
    }

    $bestLag = 0
    $bestCorrelation = -2.0
    $bestOverlap = 0

    for ($lag = $minLag; $lag -le $maxLag; $lag += $stepFrames) {

        $refIndex = 0
        $compIndex = 0

        if ($lag -ge 0) {
            $compIndex = $lag
        }
        else {
            $refIndex = -$lag
        }

        $overlap = [Math]::Min($refSignal.Length - $refIndex, $compSignal.Length - $compIndex)
        if ($overlap -lt 1) { continue }

        $refSum = 0.0
        $compSum = 0.0
        $refSquares = 0.0
        $compSquares = 0.0
        $dotProduct = 0.0

        for ($i = 0; $i -lt $overlap; $i++) {
            $rVal = $refSignal[$refIndex + $i]
            $cVal = $compSignal[$compIndex + $i]

            $refSum += $rVal
            $compSum += $cVal
            $refSquares += $rVal * $rVal
            $compSquares += $cVal * $cVal
            $dotProduct += $rVal * $cVal
        }

        $refMean = $refSum / $overlap
        $compMean = $compSum / $overlap

        $refVar = $refSquares - ($overlap * $refMean * $refMean)
        $compVar = $compSquares - ($overlap * $compMean * $compMean)

        $covariance = $dotProduct - ($overlap * $refMean * $compMean)

        $correlation = 0.0
        if ($refVar -gt 1e-12 -and $compVar -gt 1e-12) {
            $correlation = $covariance / [Math]::Sqrt($refVar * $compVar)
        }
        elseif ($refVar -le 1e-12 -and $compVar -le 1e-12) {
            if ($refMean -gt 1e-6 -and [Math]::Abs($refMean - $compMean) -lt 1e-6) {
                $correlation = 1.0
            }
        }

        if ($correlation -gt $bestCorrelation -or ($correlation -eq $bestCorrelation -and $overlap -gt $bestOverlap)) {
            $bestCorrelation = $correlation
            $bestLag = $lag
            $bestOverlap = $overlap
        }

    }

    if ($bestCorrelation -lt -1.0) {
        $bestCorrelation = 0.0
    }

    $bestOffset = [Math]::Round($bestLag * $frameDuration, 6)
    $bestCorrelation = [Math]::Round($bestCorrelation, 6)

    Write-Verbose "Best timeline alignment: offset $bestOffset s (lag $bestLag frames, correlation $bestCorrelation)."

    return [PSCustomObject]@{
        BestOffset     = $bestOffset
        Correlation    = $bestCorrelation
        Confidence     = $null
        FramesCompared = $bestOverlap
        SearchWindow   = $effectiveSearchWindow
    }

}
