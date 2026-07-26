function Get-PCXChapterStreams {

    <#
    .SYNOPSIS
        Returns all chapters from an FFprobe result.
    
    .DESCRIPTION
        Extracts chapter information from the raw FFprobe output.
    
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
    
        if (-not ($InputObject.PSObject.Properties.Name -contains 'chapters')) {
            return @()
        }
    
        @(
            $InputObject.chapters
        )
    
    }