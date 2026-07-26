function ConvertTo-PCXMediaStreams {

    <#
    .SYNOPSIS
        Converts FFprobe streams into PCXLab.MediaStream objects.
    #>
    
        [CmdletBinding()]
        [OutputType([PSCustomObject[]])]
        param(
    
            [Parameter(Mandatory)]
            [ValidateNotNull()]
            [psobject]$InputObject
    
        )
    
        foreach ($Stream in @($InputObject.streams)) {
    
            New-PCXMediaStreamObject `
                -Index ([int]$Stream.index) `
                -StreamType $Stream.codec_type `
                -Codec $Stream.codec_name `
                -Profile $Stream.profile `
                -Language $Stream.tags.language `
                -Default ([bool]$Stream.disposition.default) `
                -Forced ([bool]$Stream.disposition.forced)
    
        }
    
    }