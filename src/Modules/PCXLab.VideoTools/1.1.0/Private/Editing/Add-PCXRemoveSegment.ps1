function Add-PCXRemoveSegment {

    <#
    .SYNOPSIS
        Creates a video segment marked for removal.
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
        -Action 'Remove'

}