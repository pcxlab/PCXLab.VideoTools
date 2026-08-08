function ConvertTo-PCXAudioFilter {

    <#
    .SYNOPSIS
        Builds an FFmpeg audio filter chain string from a settings object.

    .DESCRIPTION
        Converts a settings object into a valid FFmpeg audio filter chain
        string. Each enabled audio setting appends the corresponding FFmpeg
        filter expression to the chain. Filters are joined with commas in
        the order they are evaluated.

        Returns an empty string when no audio filters are enabled, so the
        caller can safely skip the -af argument entirely.

        This function does NOT execute FFmpeg, create editing jobs, modify
        video filters, or build concat filter graphs. Its sole responsibility
        is to produce the audio filter chain string.

    .PARAMETER Settings
        A settings object that may contain the following boolean or switch
        properties:

          Normalize        - Enables loudness normalization (loudnorm).
          Compression      - Enables dynamic range compression (acompressor).
          RepairChannels   - Enables dual-mono repair for mono sources
                             recorded as stereo (pan=stereo|c0=c0|c1=c0).

        Missing or null properties are treated as disabled. Any unknown
        properties are silently ignored, making the function forward-compatible
        with future settings additions.

    .OUTPUTS
        System.String

        An empty string when no filters are enabled, or a comma-separated
        FFmpeg audio filter chain such as:

          loudnorm
          loudnorm,acompressor
          pan=stereo|c0=c0|c1=c0
          loudnorm,acompressor,pan=stereo|c0=c0|c1=c0

    .EXAMPLE
        $Settings = [PSCustomObject]@{ Normalize = $true }
        ConvertTo-PCXAudioFilter -Settings $Settings

        Returns 'loudnorm'.

    .EXAMPLE
        $Settings = [PSCustomObject]@{
            Normalize    = $true
            Compression  = $true
        }
        ConvertTo-PCXAudioFilter -Settings $Settings

        Returns 'loudnorm,acompressor'.

    .EXAMPLE
        $Settings = [PSCustomObject]@{
            Normalize      = $true
            Compression    = $true
            RepairChannels = $true
        }
        ConvertTo-PCXAudioFilter -Settings $Settings

        Returns 'loudnorm,acompressor,pan=stereo|c0=c0|c1=c0'.

    .EXAMPLE
        $Settings = [PSCustomObject]@{}
        ConvertTo-PCXAudioFilter -Settings $Settings

        Returns '' (empty string). The caller should omit the -af argument.

    .NOTES
        Internal function. Do not call directly from outside the module.

        To add a new audio filter in the future, append a single entry to
        the $FilterMap ordered hashtable. No other code needs to change.
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Settings

    )

    #----------------------------------------------------------
    # Filter map — ordered so filters are applied consistently.
    # Each entry: SettingName => FFmpeg filter expression.
    # To add a future filter, append one line here and nowhere else.
    #----------------------------------------------------------

    $FilterMap = [ordered]@{

        Normalize      = 'loudnorm'
        Compression    = 'acompressor'
        RepairChannels = 'pan=stereo|c0=c0|c1=c0'

        # Future filters — uncomment and fill in the expression:
        # NoiseReduction = 'afftdn'
        # EchoReduction  = 'aecho=0.8:0.88:60:0.4'
        # VoiceBoost     = 'equalizer=f=3000:width_type=o:width=2:g=3'
        # HighPass       = 'highpass=f=80'
        # LowPass        = 'lowpass=f=16000'
        # Equalizer      = ''
        # Limiter        = 'alimiter=level_in=1:level_out=1:limit=1:attack=7:release=100'

    }

    #----------------------------------------------------------
    # Build the filter list
    #----------------------------------------------------------

    $Filters = [System.Collections.Generic.List[string]]::new()

    foreach ($Key in $FilterMap.Keys) {

        $Property = $Settings.PSObject.Properties[$Key]

        if ($null -eq $Property) {
            continue
        }

        if ($Property.Value -eq $true) {
            $Filters.Add($FilterMap[$Key])
        }

    }

    #----------------------------------------------------------
    # Return the joined filter chain, or empty string
    #----------------------------------------------------------

    if ($Filters.Count -eq 0) {
        return ''
    }

    return ($Filters -join ',')

}
