function Get-PCXMediaSourceAudioStreamSelector {

    <#
    .SYNOPSIS
        Resolves the FFmpeg audio stream selector for a media source.

    .DESCRIPTION
        Uses the existing stream-selection infrastructure to resolve the
        primary audio stream when AudioStreamIndex is -1. Validates an
        explicit AudioStreamIndex against the available audio streams.

    .PARAMETER Source
        PCXLab.MediaSource object.

    .OUTPUTS
        System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Source

    )

    if ($Source.PSTypeNames -notcontains 'PCXLab.MediaSource') {
        throw 'Source must be a PCXLab.MediaSource object.'
    }

    $mediaInfo = $Source.MediaInformation

    if (-not $mediaInfo -or ($mediaInfo.PSTypeNames -notcontains 'PCXLab.MediaInformation')) {
        throw "MediaInformation is missing for source '$($Source.Path)'"
    }

    if ($Source.AudioStreamIndex -lt 0) {

        if (-not $mediaInfo.HasAudio) {
            throw "No audio stream found in '$($Source.Path)'"
        }

        $audioInfo = $mediaInfo.Audio
        $streamIndex = 0

        if ($audioInfo -and ($audioInfo.PSTypeNames -contains 'PCXLab.AudioInformation') -and ($null -ne $audioInfo.StreamIndex)) {
            $streamIndex = $audioInfo.StreamIndex
        }

        return "a:$streamIndex"

    }

    $requestedIndex = $Source.AudioStreamIndex

    $streams = Get-PCXMediaStreams -Path $Source.Path |
        Where-Object { $_.StreamType -eq 'audio' }

    $matchingStream = $streams | Where-Object { $_.Index -eq $requestedIndex }

    if (-not $matchingStream) {
        throw "Audio stream index $requestedIndex does not exist in '$($Source.Path)'."
    }

    return "a:$requestedIndex"

}
