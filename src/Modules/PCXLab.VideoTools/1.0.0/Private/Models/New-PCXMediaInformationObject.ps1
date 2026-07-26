function New-PCXMediaInformationObject {

    <#
    .SYNOPSIS
        Creates a PCXLab.MediaInformation object.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [psobject]$Video,

        [Parameter(Mandatory)]
        [psobject]$Audio

    )

    [PSCustomObject]@{

        PSTypeName = 'PCXLab.MediaInformation'

        Video = $Video
        Audio = $Audio

    }

}