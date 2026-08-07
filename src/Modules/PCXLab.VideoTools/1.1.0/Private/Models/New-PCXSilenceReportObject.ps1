function New-PCXSilenceReportObject {

    <#
    .SYNOPSIS
        Creates a PCXLab.SilenceReport object.
    #>

    [CmdletBinding()]
    [OutputType([object])]
    param(

        [Parameter(Mandatory)]
        [string]$SourcePath,

        [Parameter(Mandatory)]
        [int]$TotalSilences,

        [Parameter(Mandatory)]
        [double]$TotalSilentSeconds,

        [Parameter(Mandatory)]
        [double]$AverageDuration,

        [Parameter(Mandatory)]
        [double]$ShortestSilence,

        [Parameter(Mandatory)]
        [double]$LongestSilence,

        [Parameter(Mandatory)]
        [int]$ShortPauses,

        [Parameter(Mandatory)]
        [int]$EditCandidates,

        [Parameter(Mandatory)]
        [int]$RecordingBreaks

    )

    [PSCustomObject]@{

        PSTypeName = 'PCXLab.SilenceReport'

        # Source
        SourcePath = $SourcePath
        Source     = [System.IO.Path]::GetFileName($SourcePath)

        # Summary
        TotalSilences      = $TotalSilences
        TotalSilentSeconds = [Math]::Round($TotalSilentSeconds, 3)

        # Statistics
        AverageDuration = [Math]::Round($AverageDuration, 3)
        ShortestSilence = [Math]::Round($ShortestSilence, 3)
        LongestSilence  = [Math]::Round($LongestSilence, 3)

        # Classification Counts
        ShortPauses     = $ShortPauses
        EditCandidates  = $EditCandidates
        RecordingBreaks = $RecordingBreaks
    }

}