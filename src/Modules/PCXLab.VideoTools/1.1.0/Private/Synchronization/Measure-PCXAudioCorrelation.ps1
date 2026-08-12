function Measure-PCXAudioCorrelation {

    <#
    .SYNOPSIS
        Measures normalized cross-correlation between two mono WAV files.

    .DESCRIPTION
        Performs deterministic multi-stage normalized cross-correlation on
        two 8 kHz mono WAV files to determine the relative lag between them.

        Stage 1: 50 Hz energy envelope coarse search.
        Stage 2: 200 Hz energy envelope candidate refinement.
        Stage 3: 8 kHz PCM final verification over a local lag range.

    .PARAMETER ReferencePath
        Path to the reference WAV file.

    .PARAMETER TargetPath
        Path to the target WAV file.

    .PARAMETER MaxOffsetSeconds
        Maximum absolute offset to search, in seconds.

    .OUTPUTS
        PCXLab.SynchronizationEvidence
    #>

    [CmdletBinding()]
    [OutputType('PCXLab.SynchronizationEvidence')]
    param(

        [Parameter(Mandatory)]
        [ValidateScript({
            Test-Path -LiteralPath $_ -PathType Leaf
        })]
        [string]$ReferencePath,

        [Parameter(Mandatory)]
        [ValidateScript({
            Test-Path -LiteralPath $_ -PathType Leaf
        })]
        [string]$TargetPath,

        [Parameter()]
        [ValidateRange(0, 300)]
        [Nullable[double]]$MaxOffsetSeconds

    )

    $sampleRate = 8000
    $coarseRate = 50
    $coarseFactor = $sampleRate / $coarseRate   # 160
    $refineRate = 200
    $refineFactor = $sampleRate / $refineRate   # 40

    $pcmWindowSeconds = 10

    $maxOffset = 60.0
    if ($null -ne $MaxOffsetSeconds) {
        $maxOffset = [double]$MaxOffsetSeconds
    }

    $referenceWindowSeconds = $maxOffset + $pcmWindowSeconds
    $targetWindowSeconds = $referenceWindowSeconds + (2 * $maxOffset)

    # Load bounded PCM blocks
    $referenceSamples = Read-PCXMonoWavSampleBlock `
        -Path $ReferencePath `
        -SampleRate $sampleRate `
        -StartSeconds 0 `
        -DurationSeconds $referenceWindowSeconds

    $targetSamples = Read-PCXMonoWavSampleBlock `
        -Path $TargetPath `
        -SampleRate $sampleRate `
        -StartSeconds 0 `
        -DurationSeconds $targetWindowSeconds

    if ($referenceSamples.Length -lt $coarseFactor) {
        throw "Reference audio is too short for correlation."
    }

    if ($targetSamples.Length -lt $coarseFactor) {
        throw "Target audio is too short for correlation."
    }

    # Center signals
    $referenceCentered = Get-PCXCenteredSignal -Samples $referenceSamples
    $targetCentered = Get-PCXCenteredSignal -Samples $targetSamples

    # Stage 1: 50 Hz coarse energy envelope search
    $coarseReference = Get-PCXEnergyEnvelope `
        -Samples $referenceCentered `
        -Factor $coarseFactor

    $coarseTarget = Get-PCXEnergyEnvelope `
        -Samples $targetCentered `
        -Factor $coarseFactor

    $coarseMaxLag = [int][Math]::Ceiling($maxOffset * $coarseRate)

    $coarseCandidates = Search-PCXNormalizedCorrelation `
        -Reference $coarseReference `
        -Target $coarseTarget `
        -MinLag (-$coarseMaxLag) `
        -MaxLag $coarseMaxLag `
        -TopCount 5

    if ($coarseCandidates.Count -eq 0) {
        throw "No correlation candidates found."
    }

    # Stage 2: 200 Hz energy envelope refinement
    $refineReference = Get-PCXEnergyEnvelope `
        -Samples $referenceCentered `
        -Factor $refineFactor

    $refineTarget = Get-PCXEnergyEnvelope `
        -Samples $targetCentered `
        -Factor $refineFactor

    $refineMaxLag = [int][Math]::Ceiling($maxOffset * $refineRate)

    $bestRefinedLag = $null
    $bestRefinedCorrelation = [double]::MinValue

    foreach ($candidate in $coarseCandidates) {

        $refineCenter = [int]($candidate.Lag * ($refineRate / $coarseRate))
        $refineStart = [Math]::Max(-$refineMaxLag, $refineCenter - 8)
        $refineEnd = [Math]::Min($refineMaxLag, $refineCenter + 8)

        $refined = Search-PCXNormalizedCorrelation `
            -Reference $refineReference `
            -Target $refineTarget `
            -MinLag $refineStart `
            -MaxLag $refineEnd `
            -TopCount 1

        if ($refined.Count -gt 0 -and $refined[0].Correlation -gt $bestRefinedCorrelation) {
            $bestRefinedCorrelation = $refined[0].Correlation
            $bestRefinedLag = $refined[0].Lag
        }

    }

    if ($null -eq $bestRefinedLag) {
        throw "Unable to refine correlation candidate."
    }

    # Stage 3: 8 kHz PCM final verification
    $pcmWindowSamples = $pcmWindowSeconds * $sampleRate
    $localSearchSamples = 400

    $pcmCenter = $bestRefinedLag * $refineFactor
    $pcmStart = $pcmCenter - $localSearchSamples
    $pcmEnd = $pcmCenter + $localSearchSamples

    $bestPcmLag = 0
    $bestPcmCorrelation = [double]::MinValue

    for ($lag = $pcmStart; $lag -le $pcmEnd; $lag++) {

        $referenceIndex = 0
        $targetIndex = 0

        if ($lag -ge 0) {
            $targetIndex = $lag
        }
        else {
            $referenceIndex = -$lag
        }

        $overlapLength = $referenceCentered.Length - $referenceIndex
        $targetAvailable = $targetCentered.Length - $targetIndex

        if ($targetAvailable -lt $overlapLength) {
            $overlapLength = $targetAvailable
        }

        if ($overlapLength -lt $pcmWindowSamples) { continue }

        $refSum = 0.0
        $targetSum = 0.0
        $refSquares = 0.0
        $targetSquares = 0.0
        $dotProduct = 0.0

        for ($i = 0; $i -lt $pcmWindowSamples; $i++) {
            $refValue = $referenceCentered[$referenceIndex + $i]
            $targetValue = $targetCentered[$targetIndex + $i]

            $refSum += $refValue
            $targetSum += $targetValue
            $refSquares += $refValue * $refValue
            $targetSquares += $targetValue * $targetValue
            $dotProduct += $refValue * $targetValue
        }

        $refMean = $refSum / $pcmWindowSamples
        $targetMean = $targetSum / $pcmWindowSamples

        $covariance = $dotProduct - ($pcmWindowSamples * $refMean * $targetMean)
        $refVariance = $refSquares - ($pcmWindowSamples * $refMean * $refMean)
        $targetVariance = $targetSquares - ($pcmWindowSamples * $targetMean * $targetMean)

        if ($refVariance -le 0 -or $targetVariance -le 0) { continue }

        $correlation = $covariance / [Math]::Sqrt($refVariance * $targetVariance)

        if ($correlation -gt $bestPcmCorrelation) {
            $bestPcmCorrelation = $correlation
            $bestPcmLag = $lag
        }

    }

    if ($bestPcmCorrelation -eq [double]::MinValue) {
        throw "Unable to compute final PCM correlation."
    }

    $referenceWindowStart = 0
    $targetWindowStart = 0

    if ($bestPcmLag -ge 0) {
        $targetWindowStart = $bestPcmLag
    }
    else {
        $referenceWindowStart = -$bestPcmLag
    }

    $description = "Normalized cross-correlation peak at lag {0} samples ({1:F3} seconds) with correlation {2:F4}." -f
        $bestPcmLag,
        ($bestPcmLag / $sampleRate),
        $bestPcmCorrelation

    New-PCXSynchronizationEvidenceObject `
        -Method 'AudioCorrelation' `
        -Correlation $bestPcmCorrelation `
        -PeakSample $bestPcmLag `
        -SampleRate $sampleRate `
        -Description $description `
        -WindowSize $pcmWindowSamples `
        -ReferenceWindowStart $referenceWindowStart `
        -TargetWindowStart $targetWindowStart

}
