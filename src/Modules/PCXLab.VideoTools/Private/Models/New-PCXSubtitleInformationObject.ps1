function New-PCXSubtitleInformationObject {

<#
.SYNOPSIS
    Creates a PCXLab.SubtitleInformation object.
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
        [int]$SubtitleStreams,

        [Parameter(Mandatory)]
        [bool]$HasVideo,

        [Parameter(Mandatory)]
        [bool]$HasAudio,

        [Parameter(Mandatory)]
        [bool]$HasSubtitles,

        [string]$SubtitleCodec,
        [string]$Language,
        [int]$StreamIndex,
        [bool]$Default,
        [bool]$Forced

    )

    [PSCustomObject]@{

        PSTypeName = 'PCXLab.SubtitleInformation'

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
        SubtitleStreams = $SubtitleStreams

        HasVideo = $HasVideo
        HasAudio = $HasAudio
        HasSubtitles = $HasSubtitles

        SubtitleCodec = $SubtitleCodec

        Language = $Language
        StreamIndex = $StreamIndex

        Default = $Default
        Forced = $Forced

    }

}