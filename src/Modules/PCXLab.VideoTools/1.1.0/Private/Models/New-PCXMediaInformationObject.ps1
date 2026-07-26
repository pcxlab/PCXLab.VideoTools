function New-PCXMediaInformationObject {

    <#
    .SYNOPSIS
        Creates a PCXLab.MediaInformation object.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [psobject]$Video,

        [Parameter(Mandatory)]
        [psobject]$Audio

    )

    [PSCustomObject]@{

        PSTypeName = 'PCXLab.MediaInformation'

        FileName       = $Video.FileName
        FullName       = $Video.FullName

        Duration       = $Video.Duration

        Resolution     = $Video.Resolution

        VideoCodec     = $Video.VideoCodec
        AudioCodec     = $Audio.AudioCodec

        FileSize       = $Video.FileSize
        FileSizeText   = $Video.FileSizeText

        BitRate        = $Video.BitRate
        BitRateText    = $Video.BitRateText

        FormatName     = $Video.FormatName
        FormatLong     = $Video.FormatLong

        VideoStreams   = $Video.VideoStreams
        AudioStreams   = $Video.AudioStreams

        HasVideo       = $Video.HasVideo
        HasAudio       = $Video.HasAudio

        Video          = $Video
        Audio          = $Audio

    }

}