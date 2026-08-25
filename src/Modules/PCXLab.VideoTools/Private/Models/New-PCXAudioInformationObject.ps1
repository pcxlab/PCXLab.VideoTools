function New-PCXAudioInformationObject {

    <#
    .SYNOPSIS
        Creates a PCXLab.AudioInformation object.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [string]$FileName,

        [Parameter(Mandatory)]
        [string]$FullName,

        [Parameter(Mandatory)]
        [timespan]$Duration,

        [Parameter(Mandatory)]
        [long]$FileSize,

        [Parameter(Mandatory)]
        [string]$FileSizeText,

        [Parameter(Mandatory)]
        [long]$BitRate,

        [Parameter(Mandatory)]
        [string]$BitRateText,

        [Parameter(Mandatory)]
        [string]$FormatName,

        [Parameter(Mandatory)]
        [string]$FormatLong,

        [Parameter(Mandatory)]
        [int]$VideoStreams,

        [Parameter(Mandatory)]
        [int]$AudioStreams,

        [Parameter(Mandatory)]
        [bool]$HasVideo,

        [Parameter(Mandatory)]
        [bool]$HasAudio,

        [string]$AudioCodec,
        [string]$AudioProfile,
        [int]$Channels,
        [string]$ChannelLayout,
        [int]$SampleRate,
        [string]$SampleFormat,
        [string]$Language,
        [int]$StreamIndex,
        [bool]$Default,
        [bool]$Forced

    )

    [PSCustomObject]@{

        PSTypeName = 'PCXLab.AudioInformation'

        FileName = $FileName
        FullName = $FullName

        Duration = $Duration

        FileSize = $FileSize
        FileSizeText = $FileSizeText

        BitRate = $BitRate
        BitRateText = $BitRateText

        FormatName = $FormatName
        FormatLong = $FormatLong

        VideoStreams = $VideoStreams
        AudioStreams = $AudioStreams

        HasVideo = $HasVideo
        HasAudio = $HasAudio

        AudioCodec = $AudioCodec
        AudioProfile = $AudioProfile

        Channels = $Channels
        ChannelLayout = $ChannelLayout

        SampleRate = $SampleRate
        SampleFormat = $SampleFormat

        Language = $Language
        StreamIndex = $StreamIndex

        Default = $Default
        Forced = $Forced

    }

}