function Get-PCXCenteredSignal {

    <#
    .SYNOPSIS
        Centers a sample array by subtracting its mean.

    .DESCRIPTION
        Returns a new double array containing the input samples with
        their mean removed.

    .PARAMETER Samples
        Input sample array.

    .OUTPUTS
        System.Double[]
    #>

    [CmdletBinding()]
    [OutputType([double[]])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Int16[]]$Samples

    )

    $mean = 0.0
    foreach ($value in $Samples) {
        $mean += $value
    }
    $mean /= $Samples.Length

    $centered = [double[]]::new($Samples.Length)
    for ($i = 0; $i -lt $Samples.Length; $i++) {
        $centered[$i] = $Samples[$i] - $mean
    }

    return $centered

}
