function Add-PCXKeepSegment {

    <#
    .SYNOPSIS
        Creates a video segment marked to keep.

    .DESCRIPTION
        Creates a PCXLab.VideoSegment object representing a section
        of video that should be retained.

    .PARAMETER SourcePath
        Source media file.

    .PARAMETER Start
        Segment start time.

    .PARAMETER End
        Segment end time.

    .OUTPUTS
        PCXLab.VideoSegment
    #>

    [CmdletBinding()]
    [OutputType('PCXLab.VideoSegment')]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,

        [Parameter(Mandatory)]
        [TimeSpan]$Start,

        [Parameter(Mandatory)]
        [TimeSpan]$End

    )

    if ($End -le $Start) {
        throw 'End time must be greater than Start time.'
    }

    New-PCXVideoSegmentObject `
        -SourcePath $SourcePath `
        -Start $Start `
        -End $End `
        -Action 'Keep'

}