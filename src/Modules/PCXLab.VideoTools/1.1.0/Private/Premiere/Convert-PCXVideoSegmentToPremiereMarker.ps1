function Convert-PCXVideoSegmentToPremiereMarker {

    <#
    .SYNOPSIS
        Converts a PCXLab.VideoSegment into a normalized Premiere marker object.

    .DESCRIPTION
        Transforms an editing video segment into a PCXLab.PremiereMarker.

    .PARAMETER Segment
        The PCXLab.VideoSegment object to convert.

    .OUTPUTS
        PCXLab.PremiereMarker
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Segment

    )

    if ($Segment.PSTypeNames -notcontains 'PCXLab.VideoSegment') {
        throw 'InputObject must be a PCXLab.VideoSegment object.'
    }

    $invariantCulture = [System.Globalization.CultureInfo]::InvariantCulture

    $startSeconds = if ($null -ne $Segment.StartSeconds) {
        [double]$Segment.StartSeconds
    }
    elseif ($Segment.Start -is [TimeSpan]) {
        $Segment.Start.TotalSeconds
    }
    else {
        0.0
    }

    $endSeconds = if ($null -ne $Segment.EndSeconds) {
        [double]$Segment.EndSeconds
    }
    elseif ($Segment.End -is [TimeSpan]) {
        $Segment.End.TotalSeconds
    }
    else {
        $startSeconds
    }

    $durationSeconds = if ($null -ne $Segment.DurationSeconds) {
        [double]$Segment.DurationSeconds
    }
    elseif ($Segment.Duration -is [TimeSpan]) {
        $Segment.Duration.TotalSeconds
    }
    else {
        ($endSeconds - $startSeconds)
    }

    $durationStr = $durationSeconds.ToString('0.###', $invariantCulture)
    $action = $Segment.Action

    New-PCXPremiereMarkerObject `
        -StartSeconds $startSeconds `
        -EndSeconds $endSeconds `
        -Name "VideoSegment - $action" `
        -Comments "Detected segment: $durationStr seconds. Action: $action."

}
