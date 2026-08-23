function Resolve-PCXPremiereMarkerColor {

    <#
        .SYNOPSIS
            Resolves the Premiere Pro marker color for a marker object.

        .DESCRIPTION
            Returns the Adobe Premiere Pro marker color index associated with a
            PCXLab.PremiereMarker.

            If the marker already specifies an explicit ColorIndex, that value is
            returned unchanged.

            Otherwise, a default color is selected based on the marker name.

        .NOTES
            Premiere Pro marker color indices were verified using Adobe Premiere
            Pro 25.x.

            Color Mapping:

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

    if ($null -ne $Marker.ColorIndex) {
        return $Marker.ColorIndex
    }

    #
    # Default mapping.
    #

    # Verified with Adobe Premiere Pro 25.x marker color mapping.

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
            return 6   # Blue (Information / Default)
        }

    }

}