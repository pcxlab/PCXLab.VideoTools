function ConvertTo-PCXAudioInformation {

<#
.SYNOPSIS
    Converts FFprobe output into a PCXLab audio information object.
#>

[CmdletBinding()]
[OutputType([PSCustomObject])]
param(
    [Parameter(Mandatory)]
    [psobject]$InputObject
)

$Format = $InputObject.format

$AudioStreams = $InputObject.streams |
    Where-Object codec_type -eq 'audio'

foreach($AudioStream in $AudioStreams){

    [PSCustomObject]@{

        PSTypeName = 'PCXLab.AudioInformation'

        FileName      = [System.IO.Path]::GetFileName($Format.filename)
        FullName      = $Format.filename

        AudioCodec    = $AudioStream.codec_name
        Profile       = $AudioStream.profile
        Channels      = $AudioStream.channels
        ChannelLayout = $AudioStream.channel_layout
        SampleRate    = [int]$AudioStream.sample_rate
        SampleFormat  = $AudioStream.sample_fmt
        BitRate       = [int64]$AudioStream.bit_rate
        BitRateText   = ConvertTo-PCXBitRate -BitRate ([int64]$AudioStream.bit_rate)

        Duration      = ConvertTo-PCXDuration -Seconds ([double]$Format.duration)

        FormatName    = $Format.format_name
        FormatLong    = $Format.format_long_name
    }

}

}
