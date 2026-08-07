function ConvertTo-PCXTimeSpan {

    [CmdletBinding()]
    [OutputType([TimeSpan])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$InputObject

    )

    if ($InputObject -is [TimeSpan]) {
        return $InputObject
    }

    return [TimeSpan]::FromTicks([Int64]$InputObject.Ticks)

}