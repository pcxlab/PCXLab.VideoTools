function ConvertTo-PCXVideoInformation {

    <#
    .SYNOPSIS
        Converts FFprobe output into a PCXLab video information object.
    
    .DESCRIPTION
        Converts the raw FFprobe JSON object into a standardized
        PowerShell object used throughout the PCXLab.VideoTools module.
    
    .PARAMETER InputObject
        Raw FFprobe object returned by Invoke-PCXFFprobe.
    
    .OUTPUTS
        PCXLab.VideoInformation
    
    .NOTES
        Internal function.
    #>
    
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
    
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [psobject]$InputObject
    
    )
    
    #----------------------------------------------------------
    # Format Information
    #----------------------------------------------------------

    $FormatInfo = Get-PCXFormatInformation -InputObject $InputObject
    
    #----------------------------------------------------------
    # Streams
    #----------------------------------------------------------

    $VideoStreams = Get-PCXVideoStreams -InputObject $InputObject
    $AudioStreams = Get-PCXAudioStreams -InputObject $InputObject

    $VideoStream = Get-PCXPrimaryVideoStream -InputObject $InputObject
    $AudioStream = Get-PCXPrimaryAudioStream -InputObject $InputObject
    
    #----------------------------------------------------------
    # Return Object
    #----------------------------------------------------------

    New-PCXVideoInformationObject `
        -FileName $FormatInfo.FileName `
        -FullName $FormatInfo.FullName `
        -Duration $FormatInfo.Duration `
        -FileSize $FormatInfo.FileSize `
        -FileSizeText $FormatInfo.FileSizeText `
        -BitRate $FormatInfo.BitRate `
        -BitRateText $FormatInfo.BitRateText `
        -FormatName $FormatInfo.FormatName `
        -FormatLong $FormatInfo.FormatLong `
        -VideoStreams $VideoStreams.Count `
        -AudioStreams $AudioStreams.Count `
        -HasVideo ($VideoStreams.Count -gt 0) `
        -HasAudio ($AudioStreams.Count -gt 0) `
        -VideoCodec $VideoStream.codec_name `
        -VideoProfile $VideoStream.profile `
        -Width $VideoStream.width `
        -Height $VideoStream.height `
        -Resolution ('{0} x {1}' -f $VideoStream.width, $VideoStream.height) `
        -PixelFormat $VideoStream.pix_fmt `
        -FrameRate (ConvertTo-PCXFrameRate -FrameRate $VideoStream.r_frame_rate) `
        -Language $VideoStream.tags.language `
        -StreamIndex $VideoStream.index `
        -Default ([bool]$VideoStream.disposition.default) `
        -Forced ([bool]$VideoStream.disposition.forced) `
        -AudioCodec $AudioStream.codec_name    
}