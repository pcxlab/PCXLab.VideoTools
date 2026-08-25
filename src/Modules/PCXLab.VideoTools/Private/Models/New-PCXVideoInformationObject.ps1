function New-PCXVideoInformationObject {

    <#
    .SYNOPSIS
        Creates a PCXLab.VideoInformation object.
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

        [string]$VideoCodec,
        [string]$VideoProfile,

        [int]$Width,
        [int]$Height,

        [string]$Resolution,

        [string]$PixelFormat,

        [double]$FrameRate,

        [string]$Language,

        [int]$StreamIndex,

        [bool]$Default,

        [bool]$Forced,

        [string]$AudioCodec

    )

    [PSCustomObject]@{

        PSTypeName = 'PCXLab.VideoInformation'

        FileName     = $FileName
        FullName     = $FullName

        Duration     = $Duration

        FileSize     = $FileSize
        FileSizeText = $FileSizeText

        BitRate      = $BitRate
        BitRateText  = $BitRateText

        FormatName   = $FormatName
        FormatLong   = $FormatLong

        VideoStreams = $VideoStreams
        AudioStreams = $AudioStreams

        HasVideo     = $HasVideo
        HasAudio     = $HasAudio

        VideoCodec   = $VideoCodec
        VideoProfile = $VideoProfile

        Width        = $Width
        Height       = $Height

        Resolution   = $Resolution

        PixelFormat  = $PixelFormat

        FrameRate    = $FrameRate

        Language     = $Language

        StreamIndex  = $StreamIndex

        Default      = $Default
        Forced       = $Forced

        AudioCodec   = $AudioCodec

    }

}