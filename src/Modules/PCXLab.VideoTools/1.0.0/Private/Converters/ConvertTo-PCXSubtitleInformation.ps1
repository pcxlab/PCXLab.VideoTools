function ConvertTo-PCXSubtitleInformation {

<#
.SYNOPSIS
    Converts FFprobe output into a PCXLab subtitle information object.

.DESCRIPTION
    Converts the raw FFprobe JSON object into a standardized
    PowerShell object used throughout the PCXLab.VideoTools module.

.PARAMETER InputObject
    Raw FFprobe object returned by Invoke-PCXFFprobe.

.OUTPUTS
    PCXLab.SubtitleInformation

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
    $SubtitleStreams = Get-PCXSubtitleStreams -InputObject $InputObject

    $SubtitleStream = Get-PCXPrimarySubtitleStream -InputObject $InputObject

    if (-not $SubtitleStream) {
        return $null
    }

    #----------------------------------------------------------
    # Return Object
    #----------------------------------------------------------

    return New-PCXSubtitleInformationObject `
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
        -SubtitleStreams $SubtitleStreams.Count `
        -HasVideo ($VideoStreams.Count -gt 0) `
        -HasAudio ($AudioStreams.Count -gt 0) `
        -HasSubtitles ($SubtitleStreams.Count -gt 0) `
        -SubtitleCodec $SubtitleStream.codec_name `
        -Language $SubtitleStream.tags.language `
        -StreamIndex ([int]$SubtitleStream.index) `
        -Default ([bool]$SubtitleStream.disposition.default) `
        -Forced ([bool]$SubtitleStream.disposition.forced)

}