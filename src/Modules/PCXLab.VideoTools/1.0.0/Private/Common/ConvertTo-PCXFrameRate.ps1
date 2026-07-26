function ConvertTo-PCXFrameRate {

    <#
    .SYNOPSIS
        Converts an FFprobe frame rate value into a decimal value.

    .DESCRIPTION
        FFprobe typically returns frame rates as fractions
        (for example "30000/1001"). This function converts the
        fraction into a numeric frame rate suitable for reporting.

    .PARAMETER FrameRate
        Frame rate returned by FFprobe.

    .EXAMPLE
        ConvertTo-PCXFrameRate -FrameRate "30000/1001"

    .EXAMPLE
        ConvertTo-PCXFrameRate -FrameRate "25"

    .OUTPUTS
        System.Double

    .NOTES
        Internal function.
    #>

    [CmdletBinding()]
    [OutputType([double])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FrameRate

    )

    if ($FrameRate -match '^(\d+)\/(\d+)$') {

        $Numerator   = [double]$Matches[1]
        $Denominator = [double]$Matches[2]

        if ($Denominator -eq 0) {
            return 0
        }

        return [Math]::Round(($Numerator / $Denominator), 3)

    }

    return [double]$FrameRate

}