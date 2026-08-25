function Get-PCXPrimaryVideoStream {

    <#
    .SYNOPSIS
        Returns the primary video stream from an FFprobe result.
    #>
    
        [CmdletBinding()]
        [OutputType([psobject])]
        param(
    
            [Parameter(Mandatory)]
            [ValidateNotNull()]
            [psobject]$InputObject
    
        )
    
        $VideoStreams = Get-PCXVideoStreams -InputObject $InputObject
    
        if ($VideoStreams.Count -eq 0) {
            return $null
        }
    
        return $VideoStreams[0]
    
    }