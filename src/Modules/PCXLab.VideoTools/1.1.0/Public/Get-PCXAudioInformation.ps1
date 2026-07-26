function Get-PCXAudioInformation {

<#
.SYNOPSIS
    Gets information about one or more audio streams in media files.
#>

[CmdletBinding()]
[OutputType('PCXLab.AudioInformation')]
param(
    [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [Alias('FullName')]
    [string[]]$Path
)

process {

    foreach($MediaFile in $Path){

        $RawAudioInformation = Invoke-PCXFFprobe -Path $MediaFile

        ConvertTo-PCXAudioInformation -InputObject $RawAudioInformation

    }

}

}
