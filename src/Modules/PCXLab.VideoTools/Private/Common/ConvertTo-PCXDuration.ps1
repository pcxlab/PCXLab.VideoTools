function ConvertTo-PCXDuration {

    [CmdletBinding()]
    [OutputType([TimeSpan])]
    param(
        [Parameter(Mandatory)]
        [double]$Seconds
    )

    return [TimeSpan]::FromMilliseconds(
        [Math]::Round($Seconds * 1000)
    )
}