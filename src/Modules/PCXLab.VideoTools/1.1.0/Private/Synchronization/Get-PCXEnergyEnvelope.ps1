function Get-PCXEnergyEnvelope {

    <#
    .SYNOPSIS
        Builds a mean-absolute energy envelope from a centered signal.

    .DESCRIPTION
        Downsamples a centered sample array by a given factor, returning
        the mean absolute amplitude for each block.

    .PARAMETER Samples
        Centered input samples.

    .PARAMETER Factor
        Downsampling factor.

    .OUTPUTS
        System.Double[]
    #>

    [CmdletBinding()]
    [OutputType([double[]])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [double[]]$Samples,

        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Factor

    )

    $envelopeLength = [int][Math]::Floor($Samples.Length / $Factor)
    $envelope = [double[]]::new($envelopeLength)

    for ($i = 0; $i -lt $envelopeLength; $i++) {

        $start = $i * $Factor
        $sum = 0.0

        for ($j = 0; $j -lt $Factor; $j++) {
            $sum += [Math]::Abs($Samples[$start + $j])
        }

        $envelope[$i] = $sum / $Factor

    }

    return $envelope

}
