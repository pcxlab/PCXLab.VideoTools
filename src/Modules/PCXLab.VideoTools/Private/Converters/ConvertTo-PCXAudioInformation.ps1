function ConvertTo-PCXAudioInformation {

    <#
    .SYNOPSIS
        Converts FFprobe output into a PCXLab audio information object.

    .DESCRIPTION
        Converts the raw FFprobe JSON object into a standardized
        PowerShell object used throughout the PCXLab.VideoTools module.

    .PARAMETER InputObject
        Raw FFprobe object returned by Invoke-PCXFFprobe.

    .OUTPUTS
        PCXLab.AudioInformation

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

    $AudioStream = Get-PCXPrimaryAudioStream -InputObject $InputObject

    if (-not $AudioStream) {
        return $null
    }

    #----------------------------------------------------------
    # Return Object
    #----------------------------------------------------------

    return New-PCXAudioInformationObject `
        -FileName ([System.IO.Path]::GetFileName($Format.filename)) `
        -FullName $Format.filename `
        -Duration (ConvertTo-PCXDuration -Seconds ([double]$Format.duration)) `
        -FileSize ([Int64]$Format.size) `
        -FileSizeText (ConvertTo-PCXFileSize -Bytes ([Int64]$Format.size)) `
        -BitRate ([Int64]$Format.bit_rate) `
        -BitRateText (ConvertTo-PCXBitRate -BitRate ([Int64]$Format.bit_rate)) `
        -FormatName $Format.format_name `
        -FormatLong $Format.format_long_name `
        -VideoStreams $VideoStreams.Count `
        -AudioStreams $AudioStreams.Count `
        -HasVideo ($VideoStreams.Count -gt 0) `
        -HasAudio ($AudioStreams.Count -gt 0) `
        -AudioCodec $AudioStream.codec_name `
        -AudioProfile $AudioStream.profile `
        -Channels ([int]$AudioStream.channels) `
        -ChannelLayout $AudioStream.channel_layout `
        -SampleRate ([int]$AudioStream.sample_rate) `
        -SampleFormat $AudioStream.sample_fmt `
        -Language $AudioStream.tags.language `
        -StreamIndex $AudioStream.index `
        -Default ([bool]$AudioStream.disposition.default) `
        -Forced ([bool]$AudioStream.disposition.forced)

}