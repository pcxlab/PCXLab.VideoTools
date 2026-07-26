function Get-PCXPrimarySubtitleStream {

    <#
    .SYNOPSIS
        Returns the primary subtitle stream from an FFprobe result.
    #>
    
        [CmdletBinding()]
        [OutputType([psobject])]
        param(
    
            [Parameter(Mandatory)]
            [ValidateNotNull()]
            [psobject]$InputObject
    
        )
    
        $SubtitleStreams = @(Get-PCXSubtitleStreams -InputObject $InputObject)
    
        if ($SubtitleStreams.Count -eq 0) {
            return $null
        }
    
        return $SubtitleStreams[0]
    
    }