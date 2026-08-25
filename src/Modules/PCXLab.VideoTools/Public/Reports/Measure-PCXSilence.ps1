function Measure-PCXSilence {

    <#
    .SYNOPSIS
        Calculates summary statistics for silence analysis.

    .DESCRIPTION
        Accepts PCXLab.Silence objects from the pipeline and produces
        an aggregate report containing silence counts, durations,
        classifications, and timing statistics.

    .EXAMPLE
        Find-PCXSilence -Path .\Video.mp4 |
            Measure-PCXSilence

    .EXAMPLE
        Import-PCXSilence .\Video.silence.json |
            Measure-PCXSilence
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [ValidateNotNull()]
        [object]$InputObject

    )

    begin {

        $silence = [System.Collections.Generic.List[object]]::new()

    }

    process {

        if ($InputObject.PSTypeNames -notcontains 'PCXLab.Silence') {
            throw 'InputObject must be a PCXLab.Silence object.'
        }

        $silence.Add($InputObject)

    }

    end {

        if ($silence.Count -eq 0) {
            return
        }

        $durations = $silence.DurationSeconds

        New-PCXSilenceReportObject `
            -SourcePath $silence[0].SourcePath `
            -TotalSilences $silence.Count `
            -TotalSilentSeconds (($durations | Measure-Object -Sum).Sum) `
            -AverageDuration (($durations | Measure-Object -Average).Average) `
            -ShortestSilence (($durations | Measure-Object -Minimum).Minimum) `
            -LongestSilence (($durations | Measure-Object -Maximum).Maximum) `
            -ShortPauses (@($silence | Where-Object Classification -eq 'ShortPause').Count) `
            -EditCandidates (@($silence | Where-Object Classification -eq 'EditCandidate').Count) `
            -RecordingBreaks (@($silence | Where-Object Classification -eq 'RecordingBreak').Count)

    }

}