function Get-PCXSubtitleStreams {

    <#
    .SYNOPSIS
        Returns all subtitle streams from an FFprobe result.
    
    .DESCRIPTION
        Extracts subtitle streams from the raw FFprobe output.
    
    .PARAMETER InputObject
        Raw FFprobe object returned by Invoke-PCXFFprobe.
    
    .OUTPUTS
        System.Object[]
    #>
    
        [CmdletBinding()]
        [OutputType([psobject[]])]
        param(
    
            [Parameter(Mandatory)]
            [ValidateNotNull()]
            [psobject]$InputObject
    
        )
    
        @(
            $InputObject.streams |
            Where-Object { $_.codec_type -eq 'subtitle' }
        )
    
    }