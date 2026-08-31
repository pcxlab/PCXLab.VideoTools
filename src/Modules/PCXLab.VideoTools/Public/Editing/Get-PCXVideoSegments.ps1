function Get-PCXVideoSegments {

    <#
    .SYNOPSIS
        Builds video editing segments from analysis events or analysis containers.

    .DESCRIPTION
        Converts temporal analysis events (such as silence, black frames, or
        future analysis detections) or complete PCXLab.VideoAnalysis objects
        into PCXLab.VideoSegment objects representing both sections to keep
        and sections to remove.

    .PARAMETER InputObject
        One or more analysis event objects or a PCXLab.VideoAnalysis container
        received from the pipeline.

    .OUTPUTS
        PCXLab.VideoSegment
    #>

    [CmdletBinding()]
    [OutputType('PCXLab.VideoSegment')]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [ValidateNotNull()]
        [object]$InputObject

    )

    begin {

        $Events = [System.Collections.Generic.List[object]]::new()
        $VideoAnalysis = $null

    }

    process {

        if ($InputObject.PSTypeNames -contains 'PCXLab.VideoAnalysis') {

            if ($null -ne $VideoAnalysis -or $Events.Count -gt 0) {
                throw 'InputObject must contain either one PCXLab.VideoAnalysis object or loose analysis events, not both or multiple containers.'
            }

            $VideoAnalysis = $InputObject

            if ($null -ne $InputObject.Analysis) {

                if ($null -ne $InputObject.Analysis.Silence) {
                    foreach ($e in @($InputObject.Analysis.Silence)) {
                        if (Test-PCXAnalysisEvent -InputObject $e) {
                            $Events.Add($e)
                        }
                    }
                }

                if ($null -ne $InputObject.Analysis.BlackFrames) {
                    foreach ($e in @($InputObject.Analysis.BlackFrames)) {
                        if (Test-PCXAnalysisEvent -InputObject $e) {
                            $Events.Add($e)
                        }
                    }
                }

            }

        }
        elseif (Test-PCXAnalysisEvent -InputObject $InputObject) {

            if ($null -ne $VideoAnalysis) {
                throw 'InputObject must contain either one PCXLab.VideoAnalysis object or loose analysis events, not both.'
            }

            $Events.Add($InputObject)
        }
        else {
            throw "InputObject must be a PCXLab.VideoAnalysis object or a valid analysis event conforming to the PCXLab analysis event contract."
        }

    }

    end {

        if ($Events.Count -eq 0) {
            return
        }

        if ($null -ne $VideoAnalysis) {
            $SourcePath = [string]$VideoAnalysis.SourcePath

            if ([string]::IsNullOrWhiteSpace($SourcePath)) {
                throw 'PCXLab.VideoAnalysis must provide a non-empty SourcePath.'
            }
        }
        else {
            $uniqueSourcePaths = @($Events.SourcePath | Sort-Object -Unique)

            if ($uniqueSourcePaths.Count -gt 1) {
                throw "All input objects must belong to the same source. Found: $($uniqueSourcePaths -join ', ')."
            }

            $SourcePath = $Events[0].SourcePath
        }

        #
        # Resolve cache path using existing artifact infrastructure
        #

        $cacheFile = Get-PCXArtifactPath `
            -SourcePath $SourcePath `
            -ArtifactType VideoSegment

        #
        # Cache hit
        #

        if (Test-PCXVideoSegmentCache -Path $cacheFile) {

            Write-Verbose "Returning cached video segments from '$cacheFile'."
            Import-PCXVideoSegment -Path $cacheFile
            return

        }

        #
        # Cache miss
        #

        Write-Verbose "No cache found at '$cacheFile'. Generating video segments."

        $VideoDuration = if ($null -ne $VideoAnalysis) {
            Resolve-PCXVideoAnalysisDuration `
                -VideoAnalysis $VideoAnalysis
        }
        else {
            Get-PCXVideoDuration `
                -Path $SourcePath
        }

        $RawSegments = Select-PCXEditBoundaries `
            -Events $Events `
            -SourcePath $SourcePath `
            -Duration $VideoDuration

        $OptimizedSegments = @(
            $RawSegments | 
                Optimize-PCXVideoSegments
        )

        if ($OptimizedSegments.Count -gt 0) {

            $null = $OptimizedSegments |
                Export-PCXVideoSegment `
                    -Path $cacheFile

        }

        $OptimizedSegments

    }

}