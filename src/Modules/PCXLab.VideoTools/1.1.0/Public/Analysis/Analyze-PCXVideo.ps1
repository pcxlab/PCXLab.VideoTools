function Analyze-PCXVideo {

    <#
.SYNOPSIS
    Performs a complete analysis of one or more media files.

.DESCRIPTION
    Analyzes media information, silence, edit segments and
    silence statistics and returns a single analysis object.

.PARAMETER Path
    One or more media files.

.OUTPUTS
    PCXLab.VideoAnalysis
#>

    [CmdletBinding()]
    [OutputType('PCXLab.VideoAnalysis')]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('FullName')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter()]
        [double]$NoiseFloor = (
            Get-PCXSetting `
                -Name 'Analysis.SilenceThreshold' `
                -DefaultValue -35
        ),

        [Parameter()]
        [double]$MinimumDuration = (
            Get-PCXSetting `
                -Name 'Analysis.MinimumSilenceDuration' `
                -DefaultValue 1
        )

    )

    process {

        foreach ($MediaFile in $Path) {

            $Media = Get-PCXMediaInformation `
                -Path $MediaFile

            $Silence = @(
                Find-PCXSilence `
                    -Path $MediaFile `
                    -NoiseFloor $NoiseFloor `
                    -MinimumDuration $MinimumDuration
            )

            $Segments = if ($Silence.Count -gt 0) {
                @(
                    $Silence |
                    Get-PCXVideoSegments
                )
            }
            else {
                @(
                    Add-PCXKeepSegment `
                        -SourcePath $MediaFile `
                        -Start ([TimeSpan]::Zero) `
                        -End $Media.Duration
                )
            }

            $Statistics = $Silence |
            Measure-PCXSilence

            $Analysis = New-PCXVideoAnalysisObject `
                -SourcePath $MediaFile `
                -Media $Media `
                -Silence $Silence `
                -Segments $Segments `
                -SilenceStatistics $Statistics

            $Analysis

        }

    }
}