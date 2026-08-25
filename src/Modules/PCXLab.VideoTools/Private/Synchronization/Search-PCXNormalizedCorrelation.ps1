function Search-PCXNormalizedCorrelation {

    <#
    .SYNOPSIS
        Searches normalized correlation across a bounded lag range.

    .DESCRIPTION
        Computes normalized Pearson correlation between a reference
        envelope and a target envelope for lags in the specified range,
        returning the top correlating lags.

    .PARAMETER Reference
        Reference envelope.

    .PARAMETER Target
        Target envelope.

    .PARAMETER MinLag
        Minimum lag to search.

    .PARAMETER MaxLag
        Maximum lag to search.

    .PARAMETER TopCount
        Number of top candidates to return.

    .OUTPUTS
        System.Object[]
    #>

    [CmdletBinding()]
    [OutputType([object[]])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [double[]]$Reference,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [double[]]$Target,

        [Parameter()]
        [int]$MinLag = 0,

        [Parameter(Mandatory)]
        [int]$MaxLag,

        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$TopCount

    )

    if ($MinLag -gt $MaxLag) {
        throw 'MinLag must be less than or equal to MaxLag.'
    }

    $candidates = [System.Collections.Generic.List[object]]::new()

    for ($lag = $MinLag; $lag -le $MaxLag; $lag++) {

        $referenceIndex = 0
        $targetIndex = 0

        if ($lag -ge 0) {
            $targetIndex = $lag
        }
        else {
            $referenceIndex = -$lag
        }

        $overlapLength = $Reference.Length - $referenceIndex
        $targetAvailable = $Target.Length - $targetIndex

        if ($targetAvailable -lt $overlapLength) {
            $overlapLength = $targetAvailable
        }

        if ($overlapLength -lt 2) { continue }

        $refSum = 0.0
        $targetSum = 0.0
        $refSquares = 0.0
        $targetSquares = 0.0
        $dotProduct = 0.0

        for ($i = 0; $i -lt $overlapLength; $i++) {
            $refValue = $Reference[$referenceIndex + $i]
            $targetValue = $Target[$targetIndex + $i]

            $refSum += $refValue
            $targetSum += $targetValue
            $refSquares += $refValue * $refValue
            $targetSquares += $targetValue * $targetValue
            $dotProduct += $refValue * $targetValue
        }

        $refMean = $refSum / $overlapLength
        $targetMean = $targetSum / $overlapLength

        $covariance = $dotProduct - ($overlapLength * $refMean * $targetMean)
        $refVariance = $refSquares - ($overlapLength * $refMean * $refMean)
        $targetVariance = $targetSquares - ($overlapLength * $targetMean * $targetMean)

        if ($refVariance -le 0 -or $targetVariance -le 0) { continue }

        $correlation = $covariance / [Math]::Sqrt($refVariance * $targetVariance)

        $candidates.Add([PSCustomObject]@{
            Lag = $lag
            Correlation = $correlation
        })

    }

    return @(
        $candidates |
            Sort-Object -Property Correlation -Descending |
            Select-Object -First $TopCount
    )

}
