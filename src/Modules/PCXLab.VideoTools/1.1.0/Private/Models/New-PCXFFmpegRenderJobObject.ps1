function New-PCXFFmpegRenderJobObject {

    <#
.SYNOPSIS
    Creates a PCXLab.FFmpegRenderJob object.

.DESCRIPTION
    Represents an FFmpeg rendering execution specification containing
    the input source, output destination, compiled filter graph, and
    encoding parameters.

.OUTPUTS
    PCXLab.FFmpegRenderJob
#>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterGraph,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$VideoCodec = 'libx264',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$AudioCodec = 'aac',

        [Parameter()]
        [ValidateRange(0, 100)]
        [int]$InputIndex = 0,

        [Parameter()]
        [ValidateRange(0, 192000)]
        [int]$SampleRate = 0,

        [Parameter()]
        [bool]$HasAudio = $true

    )

    [PSCustomObject]@{

        PSTypeName  = 'PCXLab.FFmpegRenderJob'

        SourcePath  = $SourcePath

        OutputPath  = $OutputPath

        FilterGraph = $FilterGraph

        VideoCodec  = $VideoCodec

        AudioCodec  = $AudioCodec

        InputIndex  = $InputIndex

        SampleRate  = $SampleRate

        HasAudio    = $HasAudio

    }

}
