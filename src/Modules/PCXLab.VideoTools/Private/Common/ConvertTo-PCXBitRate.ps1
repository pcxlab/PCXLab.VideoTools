function ConvertTo-PCXBitRate {

    <#
    .SYNOPSIS
        Converts bits per second into a readable string.

    .PARAMETER BitRate
        Bit rate in bits per second.

    .OUTPUTS
        System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(

        [Parameter(Mandatory)]
        [Int64]$BitRate

    )

    switch ($BitRate) {

        {$_ -ge 1000000000} { return "{0:N2} Gbps" -f ($BitRate / 1000000000) }
        {$_ -ge 1000000}    { return "{0:N2} Mbps" -f ($BitRate / 1000000) }
        {$_ -ge 1000}       { return "{0:N2} Kbps" -f ($BitRate / 1000) }

        default { return "$BitRate bps" }

    }

}