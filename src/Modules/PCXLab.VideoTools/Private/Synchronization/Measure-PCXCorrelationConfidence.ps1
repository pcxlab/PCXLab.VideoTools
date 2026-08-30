function Measure-PCXCorrelationConfidence {

    <#
    .SYNOPSIS
        Computes a confidence score for a correlation result produced by
        Search-PCXAudioCorrelation.

    .DESCRIPTION
        Converts the raw evidence in a correlation result object into a single
        normalized confidence score in the range [0, 1], where 1.0 represents
        maximum confidence in the reported alignment and 0.0 represents no
        confidence.

        The score is derived from three independent evidence signals:

        1. Correlation (primary signal quality)
           The Pearson correlation coefficient at the best lag is the foundation of
           the score.  A PCC close to 1.0 indicates the two signals match well at
           the reported offset.

        2. OverlapFraction (evidence reliability weight)
           A best-lag alignment based on a small fraction of the available signal
           is structurally less trustworthy than one based on the full overlap.
           The score is scaled by OverlapFraction to penalise alignments with thin
           evidence bases.

        3. SecondPeakCorrelation (ambiguity discount)
           When an independent competing peak exists (SecondPeakCorrelation is not
           $null), the prominence gap between the primary and secondary peaks
           (Correlation - SecondPeakCorrelation) is used to scale the score.
           A near-zero gap indicates high ambiguity and reduces confidence
           toward zero.  When no independent peak exists within the search range,
           no ambiguity discount is applied.

        The result is clamped to [0, 1] and rounded to six decimal places.

    .PARAMETER CorrelationResult
        A correlation result object as returned by Search-PCXAudioCorrelation.
        Must contain: Correlation, OverlapFraction, and SecondPeakCorrelation.

    .OUTPUTS
        System.Double

    .NOTES
        Internal helper for Stage 3A confidence scoring.
        Has no dependency on media files, FFmpeg, recording sessions, Premiere,
        or synchronization orchestration.
    #>

    [CmdletBinding()]
    [OutputType([double])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$CorrelationResult

    )

    $correlation = [double]$CorrelationResult.Correlation
    $overlapFraction = [double]$CorrelationResult.OverlapFraction

    # Treat a negative primary correlation as zero signal quality.
    $baseScore = [Math]::Max(0.0, $correlation)

    # Weight by the fraction of the maximum achievable overlap that was used.
    # A result based on very little overlap is less reliable, regardless of its PCC.
    $weightedScore = $baseScore * $overlapFraction

    # Apply an ambiguity discount when a second independent peak was found.
    # The prominence gap (primary - secondary) ranges from 0 (ambiguous) to ~2
    # (unambiguous) but in practice both values are in [-1, 1], so the gap is
    # in [-2, 2].  We clamp it to [0, 1] to produce a clean multiplier:
    #   gap = 0   → multiplier = 0  → complete ambiguity, score collapses to 0
    #   gap = 0.5 → multiplier = 0.5 → moderate ambiguity
    #   gap ≥ 1   → multiplier = 1  → unambiguous, no discount applied
    if ($null -ne $CorrelationResult.SecondPeakCorrelation) {
        $secondPeak = [double]$CorrelationResult.SecondPeakCorrelation
        $prominenceGap = $correlation - $secondPeak
        $ambiguityMultiplier = [Math]::Max(0.0, [Math]::Min(1.0, $prominenceGap))
        $weightedScore = $weightedScore * $ambiguityMultiplier
    }

    $confidence = [Math]::Max(0.0, [Math]::Min(1.0, $weightedScore))

    return [Math]::Round($confidence, 6)

}
