function Get-PCXVideoDuration {

    <#
    .SYNOPSIS
        Gets the duration of a video file.

    .DESCRIPTION
        Retrieves the total duration of a media file using the existing
        PCXLab video information pipeline.

        This helper is used by the editing engine when constructing
        timeline segments.

    .PARAMETER Path
        Path to the source media file.

    .OUTPUTS
        System.TimeSpan
    #>

    [CmdletBinding()]
    [OutputType([TimeSpan])]
    param(

        [Parameter(Mandatory)]
        [ValidateScript({
            Test-Path -LiteralPath $_ -PathType Leaf
        })]
        [string]$Path

    )

    $Video = Get-PCXVideoInformation `
        -Path $Path

    return $Video.Duration

}