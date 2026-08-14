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

    $audioStreams = Get-PCXMediaStreams -Path $Source.Path |
        Where-Object { $_.StreamType -eq 'audio' } |
        Sort-Object Index

    if ($audioStreams.Count -eq 0) {
        throw "No audio stream found in '$($Source.Path)'"
    }

    if ($Source.AudioStreamIndex -lt 0) {

        $audioInfo = $mediaInfo.Audio
        $targetGlobalIndex = $audioStreams[0].Index

        if ($audioInfo -and ($audioInfo.PSTypeNames -contains 'PCXLab.AudioInformation') -and ($null -ne $audioInfo.StreamIndex)) {
            $targetGlobalIndex = $audioInfo.StreamIndex
        }

        for ($i = 0; $i -lt $audioStreams.Count; $i++) {
            if ($audioStreams[$i].Index -eq $targetGlobalIndex) {
                return "a:$i"
            }
        }

        throw "Selected audio stream index $targetGlobalIndex was not found in '$($Source.Path)'."

    }

    $requestedIndex = $Source.AudioStreamIndex

    for ($i = 0; $i -lt $audioStreams.Count; $i++) {
        if ($audioStreams[$i].Index -eq $requestedIndex) {
            return "a:$i"
        }
    }

    throw "Audio stream index $requestedIndex does not exist in '$($Source.Path)'."

}
