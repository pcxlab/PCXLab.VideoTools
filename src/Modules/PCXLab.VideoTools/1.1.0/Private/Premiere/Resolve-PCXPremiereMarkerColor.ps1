function Resolve-PCXPremiereMarkerColor {

<#
    .SYNOPSIS
        Resolves the Premiere Pro marker color for a marker object.

    .DESCRIPTION
        Returns the Adobe Premiere Pro marker color index associated with a
        PCXLab.PremiereMarker.

        If the marker already specifies an explicit ColorIndex, that value is
        returned unchanged.

        Otherwise, a default color is selected based on the semantic
        MarkerKind / MarkerSubKind values. For backward compatibility,
        legacy marker names are also supported.

    .NOTES
        Premiere Pro marker color indices verified using Adobe Premiere Pro 25.x.

        Color Mapping

            0 = Green
            1 = Red
            2 = Purple
            3 = Orange
            4 = Yellow
            5 = White
            6 = Blue
            7 = Cyan
#>

    [CmdletBinding()]
    [OutputType([Nullable[int]])]
    param(

        [Parameter(Mandatory)]
        [object]$Marker

    )

    #
    # Explicit color always wins.
    #

    if (
        $Marker.PSObject.Properties.Match('ColorIndex').Count -gt 0 -and
        $null -ne $Marker.ColorIndex
    ) {
        return $Marker.ColorIndex
    }

    #
    # Read semantic metadata.
    #

    $kind = $null
    $subKind = $null

    if ($Marker.PSObject.Properties.Match('MarkerKind').Count -gt 0) {
        $kind = $Marker.MarkerKind
    }

    if ($Marker.PSObject.Properties.Match('MarkerSubKind').Count -gt 0) {
        $subKind = $Marker.MarkerSubKind
    }

    if ($null -ne $kind) {
        $kind = $kind.Trim()
    }

    if ($null -ne $subKind) {
        $subKind = $subKind.Trim()
    }

    #
    # Semantic dispatch.
    #

    if (-not [string]::IsNullOrWhiteSpace($kind)) {

        switch ($kind) {

            'Editing' {

                switch ($subKind) {

                    'Keep' {
                        return 0   # Green
                    }

                    'Remove' {
                        return 1   # Red
                    }

                    default {
                        return 5   # White
                    }

                }

            }

            'Analysis' {

                switch ($subKind) {

                    'Silence' {
                        return 6   # Blue
                    }

                    'BlackFrame' {
                        return 2   # Purple
                    }

                    'Speech' {
                        return 7   # Cyan
                    }

                    'SceneChange' {
                        return 3   # Orange
                    }

                    'Chapter' {
                        return 4   # Yellow
                    }

                    'AISuggestion' {
                        return 2   # Purple
                    }

                    default {
                        return 6   # Blue
                    }

                }

            }

            'System' {

                switch ($subKind) {

                    'Warning' {
                        return 4   # Yellow
                    }

                    'Error' {
                        return 1   # Red
                    }

                    'Information' {
                        return 6   # Blue
                    }

                    default {
                        return 5   # White
                    }

                }

            }

            default {
                return 5   # White
            }

        }

    }

    #
    # Legacy fallback.
    #
    # Retained for backward compatibility with markers that do not
    # carry MarkerKind / MarkerSubKind.
    #

    switch ($Marker.Name) {

        { $_ -match 'Remove' } {
            return 1   # Red
        }

        { $_ -match 'Keep' } {
            return 0   # Green
        }

        { $_ -match 'Warning' } {
            return 4   # Yellow
        }

        { $_ -match 'Error' } {
            return 1   # Red
        }

        default {
            return 6   # Blue
        }

    }

}