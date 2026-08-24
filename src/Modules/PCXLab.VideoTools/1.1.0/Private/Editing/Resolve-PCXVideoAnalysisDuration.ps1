function Resolve-PCXVideoAnalysisDuration {

    <#
    .SYNOPSIS
        Resolves the duration stored in a PCXLab.VideoAnalysis object.

    .DESCRIPTION
        Reads duration metadata from the VideoAnalysis media model without
        probing the filesystem.

    .PARAMETER VideoAnalysis
        PCXLab.VideoAnalysis object containing media duration metadata.

    .OUTPUTS
        System.TimeSpan
    #>

    [CmdletBinding()]
    [OutputType([TimeSpan])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$VideoAnalysis

    )

    if ($VideoAnalysis.PSTypeNames -notcontains 'PCXLab.VideoAnalysis') {
        throw 'VideoAnalysis must be a PCXLab.VideoAnalysis object.'
    }

    if ($null -eq $VideoAnalysis.Media) {
        throw 'VideoAnalysis must contain media duration metadata.'
    }

    $duration = $null
    $durationProperty = $VideoAnalysis.Media.PSObject.Properties['Duration']

    if ($null -ne $durationProperty -and $durationProperty.Value -is [TimeSpan]) {
        $duration = $durationProperty.Value
    }
    else {
        $durationSecondsProperty = $VideoAnalysis.Media.PSObject.Properties['DurationSeconds']

        if ($null -ne $durationSecondsProperty) {
            $durationSeconds = 0.0
            if ([double]::TryParse([string]$durationSecondsProperty.Value, [Globalization.NumberStyles]::Float, [Globalization.CultureInfo]::InvariantCulture, [ref]$durationSeconds)) {
                if ([double]::IsFinite($durationSeconds) -and $durationSeconds -gt 0) {
                    $duration = [TimeSpan]::FromSeconds($durationSeconds)
                }
            }
        }
    }

    if ($null -eq $duration -or $duration -le [TimeSpan]::Zero) {
        throw 'VideoAnalysis must contain a valid positive media duration.'
    }

    return $duration

}
