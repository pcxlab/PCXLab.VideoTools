function ConvertTo-PCXPremiereMarkerScript {

    <#
    .SYNOPSIS
        Converts PCXLab silence objects into a Premiere Pro ExtendScript.

    .DESCRIPTION
        Produces an ExtendScript payload that creates range comment markers on
        the active Adobe Premiere Pro sequence.

    .PARAMETER Marker
        Silence objects to represent as Premiere Pro markers.

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
        [object[]]$Marker,

        [Parameter()]
        [double]$TimeOffsetSeconds = 0

    )

    $invariantCulture = [System.Globalization.CultureInfo]::InvariantCulture

    $markerData = foreach ($item in $Marker) {
        $start = [Math]::Round(([double]$item.StartSeconds + $TimeOffsetSeconds), 3)
        $end = [Math]::Round(([double]$item.EndSeconds + $TimeOffsetSeconds), 3)
        $duration = ([double]$item.DurationSeconds).ToString('0.###', $invariantCulture)

        [PSCustomObject]@{
            Start    = $start
            End      = $end
            Name     = "Silence - $($item.Classification)"
            Comments = "Detected silence: $duration seconds. Classification: $($item.Classification)."
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

    alert('PCXLab.VideoTools added ' + added + ' silence marker(s) to the active sequence.');
}());
"@
}
