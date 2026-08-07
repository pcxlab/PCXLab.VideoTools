function New-PCXVideoSegmentObject {

    <#
    .SYNOPSIS
        Creates a PCXLab.VideoSegment object.

    .DESCRIPTION
        Represents a contiguous segment of a source video.

        Video segments form the foundation of the editing engine and are
        consumed by exporters, automatic editing, and future integrations.

    .PARAMETER SourcePath
        Source media file.

    .PARAMETER Start
        Segment start time.

    .PARAMETER End
        Segment end time.

    .PARAMETER Action
        Editing action for this segment.

        Valid values:

        Keep
        Remove
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [string]$SourcePath,

        [Parameter(Mandatory)]
        [TimeSpan]$Start,

        [Parameter(Mandatory)]
        [TimeSpan]$End,

        [Parameter(Mandatory)]
        [ValidateSet(
            'Keep',
            'Remove'
        )]
        [string]$Action

    )

    $Duration = $End - $Start

    [PSCustomObject]@{

        PSTypeName      = 'PCXLab.VideoSegment'

        # Source

        SourcePath      = $SourcePath

        Source          = [System.IO.Path]::GetFileName($SourcePath)

        # Timeline

        Start           = $Start

        End             = $End

        Duration        = $Duration

        # Numeric

        StartSeconds    = [Math]::Round(
            $Start.TotalSeconds,
            3
        )

        EndSeconds      = [Math]::Round(
            $End.TotalSeconds,
            3
        )

        DurationSeconds = [Math]::Round(
            $Duration.TotalSeconds,
            3
        )

        # Classification

        Action          = $Action

    }

}