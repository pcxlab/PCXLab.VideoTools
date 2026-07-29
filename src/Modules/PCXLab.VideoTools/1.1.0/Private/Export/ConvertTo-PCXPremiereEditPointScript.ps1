function ConvertTo-PCXPremiereEditPointScript {

    <#
    .SYNOPSIS
        Converts silence objects into a Premiere Pro edit-point script.

    .DESCRIPTION
        Produces an ExtendScript file that uses Premiere Pro's QE razor
        operation to create edits at the start and end of each supplied
        silence region. The generated script never removes media.

    .PARAMETER Silence
        Silence objects to convert into edit points.

    .PARAMETER TimeOffsetSeconds
        Offset added to every generated edit point.

    .PARAMETER VideoTrackIndex
        Zero-based target video-track index.

    .PARAMETER AudioTrackIndex
        Zero-based target audio-track index.

    .PARAMETER AllTracks
        Creates edits on every sequence track instead of specified tracks.

    .OUTPUTS
        System.String

    .NOTES
        Internal function. The QE razor API is not part of Adobe's supported
        public scripting DOM, so it is isolated here and used only for this
        optional edit-point workflow.
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [object[]]$Silence,

        [Parameter()]
        [double]$TimeOffsetSeconds = 0,

        [Parameter()]
        [int]$FrameRate = 30,

        [Parameter()]
        [ValidateRange(0, 99)]
        [int]$VideoTrackIndex = 0,

        [Parameter()]
        [ValidateRange(0, 99)]
        [int]$AudioTrackIndex = 0,

        [Parameter()]
        [switch]$AllTracks

    )

    $editPoints = foreach ($item in $Silence) {

        ConvertTo-PCXPremiereTimecode `
            -Seconds ($item.StartSeconds + $TimeOffsetSeconds) `
            -FrameRate $FrameRate
    
        ConvertTo-PCXPremiereTimecode `
            -Seconds ($item.EndSeconds + $TimeOffsetSeconds) `
            -FrameRate $FrameRate
    }

    $editPoints = @($editPoints | Sort-Object -Unique)
    $json = ConvertTo-Json -InputObject $editPoints -Compress
    $allTracksLiteral = if ($AllTracks) { 'true' } else { 'false' }

    # NOTE:
    # The current implementation creates razor cuts on the selected video track.
    # Audio-track cutting can be added later once it has been fully implemented
    # and validated.

    @"
#target premierepro

(function () {

    var editPoints = $json;
    var videoTrackIndex = $VideoTrackIndex;
    var cutAllTracks = $allTracksLiteral;

    app.enableQE();

    var qeSequence = qe.project.getActiveSequence();

    if (!qeSequence) {
        alert('Open and select the target sequence before running this script.');
        return;
    }

    var created = 0;

    for (var index = 0; index < editPoints.length; index++) {

        var timecode = editPoints[index];

        try {

            if (cutAllTracks) {
                qeSequence.razor(timecode);
            }
            else {
                qeSequence.getVideoTrackAt(videoTrackIndex).razor(timecode);
            }

            created++;

        }
        catch (e) {

            alert(
                'Failed to create edit point at ' +
                timecode +
                '\n\n' +
                e
            );

            break;
        }
    }

    alert(
        'PCXLab.VideoTools created ' +
        created +
        ' edit point(s). No media was removed.'
    );

}());
"@
}
