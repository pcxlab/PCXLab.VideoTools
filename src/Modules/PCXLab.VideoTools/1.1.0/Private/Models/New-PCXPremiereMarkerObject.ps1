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

    .PARAMETER ColorIndex
        Optional Premiere marker color index.

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
        ColorIndex      = $ColorIndex
    }

}
