function Get-PCXVideoStreams {

    <#
    .SYNOPSIS
        Returns all video streams from an FFprobe result.
    #>
    
        [CmdletBinding()]
        [OutputType([psobject[]])]
        param(
            [Parameter(Mandatory)]
            [psobject]$InputObject
        )
    
        return @(
            $InputObject.streams |
            Where-Object codec_type -eq 'video'
        )
    
    }