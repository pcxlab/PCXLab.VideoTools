function Get-PCXVideoAnalysis {

    <#
    .SYNOPSIS
        Returns a PCXLab.VideoAnalysis result, using the cache when available.

    .DESCRIPTION
        Reuses a previously exported Analysis.json cache if one exists
        for the requested media file. If no cache exists, this command runs
        Analyze-PCXVideo, exports the result to Analysis.json, and then
        returns the analysis object directly.

        This wrapper preserves the public behavior of Analyze-PCXVideo while
        avoiding repeated expensive analysis computations.

    .PARAMETER Path
        One or more media files.

    .PARAMETER NoiseFloor
        Audio level at or below which audio is considered silence, in decibels.

    .PARAMETER MinimumDuration
        Minimum silence duration, in seconds.

    .PARAMETER CachePath
        Optional path to the Analysis.json cache file. If omitted,
        a cache named <SourceName>-Analysis.json is written beside the source.

    .EXAMPLE
        Get-PCXVideoAnalysis -Path 'C:\Videos\Tutorial.mp4'

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
        ),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$CachePath

    )

    process {

        foreach ($MediaFile in $Path) {

            #
            # Resolve cache path
            #

            $cacheFile = if ([string]::IsNullOrWhiteSpace($CachePath)) {
                Get-PCXAnalysisPath -SourcePath $MediaFile
            } else {
                $CachePath
            }

            #
            # Cache hit
            #

            if (Test-PCXVideoAnalysisCache -Path $cacheFile) {

                Write-Verbose "Returning cached video analysis from '$cacheFile'."
                Import-PCXVideoAnalysis -Path $cacheFile
                continue

            }

            #
            # Cache miss
            #

            Write-Verbose "No cache found at '$cacheFile'. Running analysis."

            $Analysis = Analyze-PCXVideo `
                -Path $MediaFile `
                -NoiseFloor $NoiseFloor `
                -MinimumDuration $MinimumDuration

            $null = $Analysis |
                Export-PCXVideoAnalysis `
                    -Path $cacheFile

            $Analysis

        }

    }

}
