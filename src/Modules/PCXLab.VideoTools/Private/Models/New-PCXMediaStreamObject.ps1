function New-PCXMediaStreamObject {

<#
.SYNOPSIS
    Creates a PCXLab.MediaStream object.
#>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [int]$Index,

        [Parameter(Mandatory)]
        [string]$StreamType,

        [string]$Codec,

        [string]$Profile,

        [string]$Language,

        [bool]$Default,

        [bool]$Forced

    )

    [PSCustomObject]@{

        PSTypeName = 'PCXLab.MediaStream'

        Index = $Index

        StreamType = $StreamType

        Codec = $Codec

        Profile = $Profile

        Language = $Language

        Default = $Default

        Forced = $Forced

    }

}