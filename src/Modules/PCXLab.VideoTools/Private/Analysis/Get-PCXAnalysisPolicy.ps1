function Get-PCXAnalysisPolicy {

    <#
    .SYNOPSIS
        Returns centralized analysis policy defaults.

    .DESCRIPTION
        Provides standard analysis policy defaults for silence and black frame
        detection, reading from module settings (Settings.json) when available
        with built-in fallback defaults.

    .OUTPUTS
        PSCustomObject
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    $silenceNoiseFloor = [double](Get-PCXSetting -Name 'Analysis.SilenceThreshold' -DefaultValue -35)
    $silenceMinDuration = [double](Get-PCXSetting -Name 'Analysis.MinimumSilenceDuration' -DefaultValue 1.0)
    $blackFrameThreshold = 0.10
    $blackFrameMinDuration = 0.5

    [PSCustomObject]@{
        PSTypeName                = 'PCXLab.AnalysisPolicy'

        SilenceNoiseFloor         = $silenceNoiseFloor
        SilenceMinimumDuration    = $silenceMinDuration

        BlackFrameThreshold       = $blackFrameThreshold
        BlackFrameMinimumDuration = $blackFrameMinDuration

        Silence                   = [PSCustomObject]@{
            NoiseFloor      = $silenceNoiseFloor
            MinimumDuration = $silenceMinDuration
        }

        BlackFrames               = [PSCustomObject]@{
            Threshold       = $blackFrameThreshold
            MinimumDuration = $blackFrameMinDuration
        }
    }

}
