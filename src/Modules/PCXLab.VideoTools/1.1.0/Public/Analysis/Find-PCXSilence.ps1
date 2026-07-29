function Find-PCXSilence {

    <#
    .SYNOPSIS
        Finds silent regions in one or more media files.

    .DESCRIPTION
        Uses FFmpeg's silencedetect filter to find audio regions below the
        requested noise floor. Results are returned as PCXLab.Silence objects
        for review or export to an editor-marker workflow.

    .PARAMETER Path
        One or more media files to analyse.

    .PARAMETER NoiseFloor
        Audio level at or below which audio is considered silence, in decibels.
        The default is -35 dB.

    .PARAMETER MinimumDuration
        Minimum silence duration, in seconds. The default is 2 seconds.

    .EXAMPLE
        Find-PCXSilence -Path 'C:\Videos\Tutorial.mp4'

    .EXAMPLE
        Get-ChildItem 'C:\Videos' -Filter *.mp4 |
            Find-PCXSilence -MinimumDuration 5 -NoiseFloor -35

    .OUTPUTS
        PCXLab.Silence
    #>

    [CmdletBinding()]
    [OutputType('PCXLab.Silence')]
    param(

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter()]
        [ValidateRange(-120, 0)]
        [double]$NoiseFloor = -35,

        [Parameter()]
        [ValidateRange(0.1, 3600)]
        [double]$MinimumDuration = 2

    )

    process {

        foreach ($mediaFile in $Path) {
            $rawOutput = Invoke-PCXSilenceDetection `
                -Path $mediaFile `
                -NoiseFloor $NoiseFloor `
                -MinimumDuration $MinimumDuration

            $rawOutput -split "`r?`n" |
                ConvertTo-PCXSilence `
                    -SourcePath $mediaFile
        }
    }
}
