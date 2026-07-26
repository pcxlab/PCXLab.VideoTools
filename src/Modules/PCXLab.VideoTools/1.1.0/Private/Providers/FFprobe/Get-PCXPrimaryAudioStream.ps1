function Get-PCXPrimaryAudioStream {

    <#
    .SYNOPSIS
        Returns the primary audio stream from an FFprobe result.
    #>
    
        [CmdletBinding()]
        [OutputType([psobject])]
        param(
    
            [Parameter(Mandatory)]
            [ValidateNotNull()]
            [psobject]$InputObject
    
        )
    
        $AudioStreams = Get-PCXAudioStreams -InputObject $InputObject
    
        if ($AudioStreams.Count -eq 0) {
            return $null
        }
    
        return $AudioStreams[0]
    
    }