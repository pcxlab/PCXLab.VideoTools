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

    $Format = $InputObject.format

    #----------------------------------------------------------
    # Streams
    #----------------------------------------------------------

    $VideoStreams = $InputObject.streams |
    Where-Object codec_type -eq 'video'

    $AudioStreams = $InputObject.streams |
    Where-Object codec_type -eq 'audio'

    $VideoStream = $VideoStreams |
    Select-Object -First 1

    $AudioStream = $AudioStreams |
    Select-Object -First 1

    #----------------------------------------------------------
    # Duration
    #----------------------------------------------------------

    $Duration = [TimeSpan]::FromSeconds(
        [double]$Format.duration
    )

    #----------------------------------------------------------
    # Return Object
    #----------------------------------------------------------

    [PSCustomObject]@{

        PSTypeName   = 'PCXLab.VideoInformation'

        #------------------------------------------------------
        # File
        #------------------------------------------------------

        FileName     = [System.IO.Path]::GetFileName($Format.filename)
        FullName     = $Format.filename

        #------------------------------------------------------
        # General
        #------------------------------------------------------

        #Duration     = $Duration
        Duration     = ConvertTo-PCXDuration -Seconds ([double]$Format.duration)

        #FileSize     = [Int64]$Format.size
        #BitRate      = [Int64]$Format.bit_rate

        FileSize     = [Int64]$Format.size
        FileSizeText = ConvertTo-PCXFileSize -Bytes ([Int64]$Format.size)

        BitRate      = [Int64]$Format.bit_rate
        BitRateText  = ConvertTo-PCXBitRate -BitRate ([Int64]$Format.bit_rate)

        FormatName   = $Format.format_name
        FormatLong   = $Format.format_long_name

        #------------------------------------------------------
        # Video
        #------------------------------------------------------

        VideoCodec   = $VideoStream.codec_name
        Width        = $VideoStream.width
        Height       = $VideoStream.height

        Resolution = '{0} x {1}' -f $VideoStream.width, $VideoStream.height
        
        PixelFormat  = $VideoStream.pix_fmt
        FrameRate    = ConvertTo-PCXFrameRate -FrameRate $VideoStream.r_frame_rate

        #------------------------------------------------------
        # Audio
        #------------------------------------------------------

        AudioCodec   = $AudioStream.codec_name

        #------------------------------------------------------
        # Streams
        #------------------------------------------------------

        VideoStreams = $VideoStreams.Count
        AudioStreams = $AudioStreams.Count

        HasVideo     = $VideoStreams.Count -gt 0
        HasAudio     = $AudioStreams.Count -gt 0
    }

}