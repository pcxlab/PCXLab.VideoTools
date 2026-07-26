function Get-PCXFormatInformation {

    <#
    .SYNOPSIS
        Returns normalized container information from FFprobe.
    #>
    
        [CmdletBinding()]
        [OutputType([psobject])]
        param(
    
            [Parameter(Mandatory)]
            [ValidateNotNull()]
            [psobject]$InputObject
    
        )
    
        $Format = $InputObject.format
    
        [PSCustomObject]@{
    
            FileName = [System.IO.Path]::GetFileName($Format.filename)
            FullName = $Format.filename
    
            Duration = ConvertTo-PCXDuration -Seconds ([double]$Format.duration)
    
            FileSize = [Int64]$Format.size
            FileSizeText = ConvertTo-PCXFileSize -Bytes ([Int64]$Format.size)
    
            BitRate = [Int64]$Format.bit_rate
            BitRateText = ConvertTo-PCXBitRate -BitRate ([Int64]$Format.bit_rate)
    
            FormatName = $Format.format_name
            FormatLong = $Format.format_long_name
    
        }
    
    }