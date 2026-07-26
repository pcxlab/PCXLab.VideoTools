function Get-PCXAudioStreams {

    <#
    .SYNOPSIS
        Returns all audio streams from an FFprobe result.
    #>
    
        [CmdletBinding()]
        [OutputType([psobject[]])]
        param(
            [Parameter(Mandatory)]
            [psobject]$InputObject
        )
    
        return @(
            $InputObject.streams |
            Where-Object codec_type -eq 'audio'
        )
    
    }