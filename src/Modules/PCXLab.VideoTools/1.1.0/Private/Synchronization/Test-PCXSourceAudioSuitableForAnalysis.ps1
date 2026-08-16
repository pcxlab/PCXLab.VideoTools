function Test-PCXSourceAudioSuitableForAnalysis {

    <#
    .SYNOPSIS
        Determines whether a media source's audio is suitable for silence analysis.

    .DESCRIPTION
        Capability check that inspects a PCXLab.MediaSource and returns $true
        if its audio stream can be used for silence analysis.

        This function does not contain workflow policy. It only answers the
        capability question.

    .PARAMETER Source
        PCXLab.MediaSource object.

    .OUTPUTS
        System.Boolean
    #>

    [CmdletBinding()]
    [OutputType([bool])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Source

    )

    Assert-PCXMediaSource -Source $Source

    if (-not $Source.MediaInformation) {
        return $false
    }

    return [bool]$Source.MediaInformation.HasAudio

}
