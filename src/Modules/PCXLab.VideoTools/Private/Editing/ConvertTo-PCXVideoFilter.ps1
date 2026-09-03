function ConvertTo-PCXVideoFilter {

    <#
    .SYNOPSIS
        Builds an FFmpeg video filter chain string from a settings or metadata object.

    .DESCRIPTION
        Converts a settings or metadata object into a valid FFmpeg video filter
        chain string. Each enabled video setting appends the corresponding FFmpeg
        filter expression to the chain. Filters are joined with commas in the
        order they are evaluated.

        Returns an empty string when no video filters are enabled.

        This function does NOT execute FFmpeg, create editing jobs, or build
        concat filter graphs. Its sole responsibility is to produce the video
        filter chain string.

    .PARAMETER Settings
        A settings or metadata object that may contain boolean or switch
        properties:

          HorizontalFlip   - Enables horizontal flipping (hflip).

        Missing or null properties are treated as disabled. Any unknown
        properties are silently ignored, making the function forward-compatible
        with future settings additions.

    .OUTPUTS
        System.String

        An empty string when no filters are enabled, or a comma-separated
        FFmpeg video filter chain such as:

          hflip

    .EXAMPLE
        $Settings = [PSCustomObject]@{ HorizontalFlip = $true }
        ConvertTo-PCXVideoFilter -Settings $Settings

        Returns 'hflip'.

    .EXAMPLE
        $Settings = [PSCustomObject]@{}
        ConvertTo-PCXVideoFilter -Settings $Settings

        Returns '' (empty string).

    .NOTES
        Internal function. Do not call directly from outside the module.

        To add a new video filter in the future, append a single entry to
        the $FilterMap ordered hashtable.
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
    # To add a future filter, append one line here.
    #----------------------------------------------------------

    $FilterMap = [ordered]@{

        HorizontalFlip = 'hflip'

        # Future filters:
        # Rotate         = 'transpose=1'
        # Scale          = 'scale=1920:1080'
        # Crop           = 'crop=w:h:x:y'

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
