function Get-PCXTimelineFeatureVector {

    <#
    .SYNOPSIS
        Extracts a numerical feature vector from an audio activity timeline.

    .DESCRIPTION
        Extracts frame measurements (currently Energy) from a timeline object
        produced by Get-PCXAudioActivity into a double array suitable for
        correlation algorithms.

    .PARAMETER Timeline
        Audio activity timeline object.

    .PARAMETER FeatureName
        Feature measurement to extract. Default is 'Energy'.

    .OUTPUTS
        System.Double[]

    .NOTES
        Internal helper for audio activity processing.
    #>

    [CmdletBinding()]
    [OutputType([double[]])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Timeline,

        [Parameter()]
        [ValidateSet('Energy', 'Peak', 'RMS', 'ZeroCrossingRate', 'SpectralFlux', 'VoiceProbability')]
        [string]$FeatureName = 'Energy'

    )

    if ($null -eq $Timeline.Frames -or $Timeline.Frames.Count -eq 0) {
        return [double[]]::new(0)
    }

    $vector = [double[]]::new($Timeline.Frames.Count)

    for ($i = 0; $i -lt $Timeline.Frames.Count; $i++) {
        $frame = $Timeline.Frames[$i]
        if ($null -ne $frame.$FeatureName) {
            $vector[$i] = [double]$frame.$FeatureName
        }
        else {
            $vector[$i] = 0.0
        }
    }

    return [double[]]$vector

}
