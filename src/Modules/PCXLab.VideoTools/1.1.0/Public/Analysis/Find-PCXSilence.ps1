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

.PARAMETER MinimumDuration
    Minimum silence duration, in seconds.

    Defaults to the module setting
    'Analysis.MinimumSilenceDuration'.
    If the setting does not exist, a default value of 1 second is used.

.EXAMPLE
    Find-PCXSilence -Path 'C:\Videos\Tutorial.mp4'

.EXAMPLE
    Get-ChildItem 'C:\Videos' -Filter *.mp4 |
        Find-PCXSilence

.EXAMPLE
    Find-PCXSilence `
        -Path 'C:\Videos\Tutorial.mp4' `
        -MinimumDuration 5 `
        -NoiseFloor -35

.OUTPUTS
    PCXLab.Silence
#>

    [CmdletBinding()]
    [OutputType('PCXLab.Silence')]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByPath'
        )]
        [Alias('FullName')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ParameterSetName = 'ByAnalysis'
        )]
        [ValidateNotNull()]
        [object]$Analysis,

        [Parameter(ParameterSetName = 'ByPath')]
        [ValidateRange(-120,0)]
        [double]$NoiseFloor = (
            Get-PCXSetting `
                -Name 'Analysis.SilenceThreshold' `
                -DefaultValue -35
        ),

        [Parameter(ParameterSetName = 'ByPath')]
        [ValidateRange(0.1,3600)]
        [double]$MinimumDuration = (
            Get-PCXSetting `
                -Name 'Analysis.MinimumSilenceDuration' `
                -DefaultValue 1
        )

    )

    process {

        if ($PSCmdlet.ParameterSetName -eq 'ByAnalysis') {

            if ($Analysis.PSTypeNames -notcontains 'PCXLab.VideoAnalysis') {
                throw 'Analysis must be a PCXLab.VideoAnalysis object.'
            }

            if ($null -eq $Analysis.Analysis.Silence) {
                return
            }

            $Analysis.Analysis.Silence

        }
        else {

            foreach ($MediaFile in $Path) {

                $RawOutput = Invoke-PCXSilenceDetection `
                    -Path $MediaFile `
                    -NoiseFloor $NoiseFloor `
                    -MinimumDuration $MinimumDuration

                $Silence = @(
                    $RawOutput -split "`r?`n" |
                    ConvertTo-PCXSilence `
                        -SourcePath $MediaFile
                )

                Write-Verbose (
                    "Detected {0} silence region(s) in '{1}'." -f
                    $Silence.Count,
                    $MediaFile
                )

                $Silence

            }

        }

    }

}