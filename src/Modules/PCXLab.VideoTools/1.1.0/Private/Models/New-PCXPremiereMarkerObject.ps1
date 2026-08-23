function New-PCXPremiereMarkerObject {

    <#
    .SYNOPSIS
        Creates a PCXLab.PremiereMarker object.

    .DESCRIPTION
        Represents a normalized Adobe Premiere Pro sequence marker definition,
        decoupling analysis events and video segments from ExtendScript generation.

    .PARAMETER StartSeconds
        Marker start position in seconds.

    .PARAMETER EndSeconds
        Marker end position in seconds.

    .PARAMETER Name
        Marker display name / title.

    .PARAMETER Comments
        Marker description / comments.

    .PARAMETER MarkerType
        Premiere marker type (default: 'Comment').

    .PARAMETER MarkerKind
        Top-level semantic category of the marker.

        Known values (free string — not validated to allow future extensibility):

            Analysis  — factual observation produced by an analysis provider
                        (e.g. Silence, BlackFrame, Speech, SceneChange)
            Editing   — policy decision produced by an editing policy
                        (e.g. Keep, Remove)
            System    — diagnostic information
                        (e.g. Warning, Error, Information)

        Defaults to 'Analysis'.

    .PARAMETER MarkerSubKind
        Second-level semantic type within the MarkerKind category.

        Known values by MarkerKind:

            Analysis  → Silence | BlackFrame | Speech | SceneChange | Chapter | AISuggestion
            Editing   → Keep | Remove
            System    → Warning | Error | Information

        Defaults to '' (empty string — resolver falls back to legacy name-based
        dispatch when MarkerSubKind is absent).

    .PARAMETER ColorIndex
        Optional Premiere marker color index.

        When specified, this value is used directly by Resolve-PCXPremiereMarkerColor
        and overrides all semantic color resolution.

    .OUTPUTS
        PCXLab.PremiereMarker
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [double]$StartSeconds,

        [Parameter(Mandatory)]
        [double]$EndSeconds,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter()]
        [string]$Comments = '',

        [Parameter()]
        [string]$MarkerType = 'Comment',

        [Parameter()]
        [string]$MarkerKind = 'Analysis',

        [Parameter()]
        [string]$MarkerSubKind = '',

        [Parameter()]
        [Nullable[int]]
        $ColorIndex = $null

    )

    $start = [Math]::Round($StartSeconds, 3)
    $end = [Math]::Round($EndSeconds, 3)
    $duration = [Math]::Round(($end - $start), 3)

    [PSCustomObject]@{
        PSTypeName      = 'PCXLab.PremiereMarker'
        StartSeconds    = $start
        EndSeconds      = $end
        DurationSeconds = $duration
        Name            = $Name
        Comments        = $Comments
        MarkerType      = $MarkerType
        MarkerKind      = $MarkerKind
        MarkerSubKind   = $MarkerSubKind
        ColorIndex      = $ColorIndex
    }

}
