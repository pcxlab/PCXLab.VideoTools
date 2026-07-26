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

        $VideoStreams = Get-PCXVideoStreams -InputObject $InputObject
        $AudioStreams = Get-PCXAudioStreams -InputObject $InputObject

        $VideoStream = Get-PCXPrimaryVideoStream -InputObject $InputObject
        $AudioStream = Get-PCXPrimaryAudioStream -InputObject $InputObject
    
        #----------------------------------------------------------
        # Return Object
        #----------------------------------------------------------
    
        [PSCustomObject]@{
    
            PSTypeName = 'PCXLab.VideoInformation'
    
            #------------------------------------------------------
            # Identity
            #------------------------------------------------------
    
            FileName = [System.IO.Path]::GetFileName($Format.filename)
            FullName = $Format.filename
    
            #------------------------------------------------------
            # Container
            #------------------------------------------------------
    
            Duration = ConvertTo-PCXDuration -Seconds ([double]$Format.duration)
    
            FileSize = [Int64]$Format.size
            FileSizeText = ConvertTo-PCXFileSize -Bytes ([Int64]$Format.size)
    
            BitRate = [Int64]$Format.bit_rate
            BitRateText = ConvertTo-PCXBitRate -BitRate ([Int64]$Format.bit_rate)
    
            FormatName = $Format.format_name
            FormatLong = $Format.format_long_name
    
            #------------------------------------------------------
            # Streams
            #------------------------------------------------------
    
            VideoStreams = $VideoStreams.Count
            AudioStreams = $AudioStreams.Count
    
            HasVideo = ($VideoStreams.Count -gt 0)
            HasAudio = ($AudioStreams.Count -gt 0)
    
            #------------------------------------------------------
            # Video
            #------------------------------------------------------
    
            VideoCodec = $VideoStream.codec_name
            VideoProfile = $VideoStream.profile
    
            Width = $VideoStream.width
            Height = $VideoStream.height
    
            Resolution = '{0} x {1}' -f $VideoStream.width, $VideoStream.height
    
            PixelFormat = $VideoStream.pix_fmt
    
            FrameRate = ConvertTo-PCXFrameRate -FrameRate $VideoStream.r_frame_rate
    
            Language = $VideoStream.tags.language
    
            StreamIndex = $VideoStream.index
    
            Default = [bool]$VideoStream.disposition.default
    
            Forced = [bool]$VideoStream.disposition.forced
    
            #------------------------------------------------------
            # Audio
            #------------------------------------------------------
    
            AudioCodec = $AudioStream.codec_name
    
        }
    
    }