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

        [Parameter()]
        [psobject]$Audio

    )

    [PSCustomObject]@{

        PSTypeName = 'PCXLab.MediaInformation'

        FileName       = $Video.FileName
        FullName       = $Video.FullName

        Duration       = $Video.Duration

        Resolution     = $Video.Resolution

        VideoCodec     = $Video.VideoCodec
        AudioCodec     = if ($Audio) { $Audio.AudioCodec } else { $null }

        FileSize       = $Video.FileSize
        FileSizeText   = $Video.FileSizeText

        BitRate        = $Video.BitRate
        BitRateText    = $Video.BitRateText

        FormatName     = $Video.FormatName
        FormatLong     = $Video.FormatLong

        VideoStreams   = $Video.VideoStreams
        AudioStreams   = if ($Audio) { $Audio.AudioStreams } else { 0 }

        HasVideo       = ($null -ne $Video)
        HasAudio       = ($null -ne $Audio)

        Video          = $Video
        Audio          = $Audio

    }

}