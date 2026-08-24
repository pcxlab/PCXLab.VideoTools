function Convert-PCXVideoAnalysisToEdited {

    <#
    .SYNOPSIS
        Projects a PCXLab.VideoAnalysis object onto the edited timeline.

    .DESCRIPTION
        Takes a full PCXLab.VideoAnalysis container and projects all contained
        analysis event collections generically onto the edited timeline space
        using a PCXLab.TimelineMap.

        Operates strictly in-memory and CPU-only without re-running FFmpeg or
        reading from disk.

    .PARAMETER VideoAnalysis
        A PCXLab.VideoAnalysis container object.

    .PARAMETER TimelineMap
        A PCXLab.TimelineMap object describing kept timeline intervals.

    .PARAMETER EditedSourcePath
        Optional path to the edited output media file.

    .OUTPUTS
        PCXLab.VideoAnalysis
    #>

    [CmdletBinding()]
    [OutputType('PCXLab.VideoAnalysis')]
    param(

        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()]
        [object]$VideoAnalysis,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$TimelineMap,

        [Parameter()]
        [string]$EditedSourcePath

    )

    process {

        if ($VideoAnalysis.PSTypeNames -notcontains 'PCXLab.VideoAnalysis') {
            throw 'VideoAnalysis must be a PCXLab.VideoAnalysis object.'
        }

        if ($TimelineMap.PSTypeNames -notcontains 'PCXLab.TimelineMap') {
            throw 'TimelineMap must be a PCXLab.TimelineMap object.'
        }

        $editedPath = if (-not [string]::IsNullOrWhiteSpace($EditedSourcePath)) {
            $EditedSourcePath
        }
        else {
            Get-PCXArtifactPath `
                -SourcePath $TimelineMap.SourcePath `
                -ArtifactType EditedVideo
        }

        $editedAnalysis = [PSCustomObject]@{
            PSTypeName = 'PCXLab.VideoAnalysis'
            SourcePath = $editedPath
            Source     = [System.IO.Path]::GetFileName($editedPath)
            Media      = [PSCustomObject]@{
                PSTypeName      = 'PCXLab.MediaInformation'
                DurationSeconds = $TimelineMap.EditedDurationSeconds
                Duration        = [TimeSpan]::FromSeconds($TimelineMap.EditedDurationSeconds)
            }
            Analysis   = [PSCustomObject]@{ }
        }

        if ($null -ne $VideoAnalysis.Analysis) {

            foreach ($prop in $VideoAnalysis.Analysis.PSObject.Properties) {

                $items = @($prop.Value)

                if ($items.Count -gt 0 -and (Test-PCXAnalysisEvent -InputObject $items[0])) {

                    $projectedEvents = @(
                        $items |
                            Convert-PCXAnalysisEventToEdited `
                                -TimelineMap $TimelineMap
                    )

                    $editedAnalysis.Analysis |
                        Add-Member `
                            -NotePropertyName $prop.Name `
                            -NotePropertyValue $projectedEvents `
                            -Force

                }
                else {

                    $editedAnalysis.Analysis |
                        Add-Member `
                            -NotePropertyName $prop.Name `
                            -NotePropertyValue $prop.Value `
                            -Force

                }

            }

        }

        return $editedAnalysis

    }

}
