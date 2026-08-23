function ConvertTo-PCXPremiereMarkerScript {

    <#
    .SYNOPSIS
        Converts Premiere marker definitions into a Premiere Pro ExtendScript.

    .DESCRIPTION
        Produces an ExtendScript payload that creates range comment markers on
        the active Adobe Premiere Pro sequence for analysis visualization or
        segment review.

    .PARAMETER Marker
        PCXLab.PremiereMarker, PCXLab.VideoSegment, or analysis event objects to represent as Premiere Pro markers.

    .PARAMETER TimeOffsetSeconds
        Offset added to every marker position. Use this when the source clip
        does not start at zero on the target sequence.

    .OUTPUTS
        System.String

    .NOTES
        Internal function.
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('Markers')]
        [object[]]$Marker,

        [Parameter()]
        [double]$TimeOffsetSeconds = 0

    )

    $markerData = foreach ($rawItem in $Marker) {

        $items = ConvertTo-PCXPremiereMarker -InputObject $rawItem

        foreach ($item in $items) {

            $start = [Math]::Round(([double]$item.StartSeconds + $TimeOffsetSeconds), 3)
            $end = [Math]::Round(([double]$item.EndSeconds + $TimeOffsetSeconds), 3)

            [PSCustomObject]@{
                Start    = $start
                End      = $end
                Name     = $item.Name
                Comments = $item.Comments
            }

        }

    }

    $json = ConvertTo-Json -InputObject @($markerData) -Compress

    @"
#target premierepro

(function () {
    var markerData = $json;
    var sequence = app.project.activeSequence;

    if (!sequence) {
        alert('Open and select the target sequence before running this script.');
        return;
    }

    var markers = sequence.markers;
    var added = 0;

    for (var index = 0; index < markerData.length; index++) {
        var item = markerData[index];
        var marker = markers.createMarker(item.Start);

        marker.name = item.Name;
        marker.comments = item.Comments;
        marker.type = 'Comment';
        marker.end = item.End;

        added++;
    }

    alert('PCXLab.VideoTools added ' + added + ' marker(s) to the active sequence.');
}());
"@
}
