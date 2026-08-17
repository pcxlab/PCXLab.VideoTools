function ConvertTo-PCXPremiereEditPointScript {

    <#
    .SYNOPSIS
        Converts PCXLab.VideoSegment objects into a Premiere Pro edit-point script.

    .DESCRIPTION
        Produces an ExtendScript file that uses Premiere Pro's QE razor
        operation to create edits at the start and end of each supplied
        segment. The generated script never removes media.

    .PARAMETER Segment
        PCXLab.VideoSegment objects to convert into edit points.

    .PARAMETER TimeOffsetSeconds
        Offset added to every generated edit point.

    .PARAMETER FrameRate
        Frame rate used for timecode conversion.

    .PARAMETER VideoTrackIndex
        Zero-based target video-track index.

    .PARAMETER AudioTrackIndex
        Zero-based target audio-track index.

    .PARAMETER TrackMode
        Controls which tracks receive edit points.

        Selected
            Creates edit points on the specified video and audio tracks.

        All
            Creates edit points on every video and audio track in the active sequence.

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
        [object[]]$Segment,

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
        [ValidateSet('Selected', 'All')]
        [string]$TrackMode = 'Selected'
    )

    foreach ($item in $Segment) {
        if ($item.PSTypeNames -notcontains 'PCXLab.VideoSegment') {
            throw 'InputObject must be a PCXLab.VideoSegment object.'
        }
    }

    $editPoints = foreach ($item in $Segment) {

        ConvertTo-PCXPremiereTimecode `
            -Seconds ($item.StartSeconds + $TimeOffsetSeconds) `
            -FrameRate $FrameRate
    
        ConvertTo-PCXPremiereTimecode `
            -Seconds ($item.EndSeconds + $TimeOffsetSeconds) `
            -FrameRate $FrameRate
    }

    $editPoints = @($editPoints | Sort-Object -Unique)
    $json = ConvertTo-Json -InputObject $editPoints -Compress
    $trackModeLiteral = "'$TrackMode'"

    @"
#target premierepro

(function () {

    // ------------------------------------------------------------------
    // Configuration
    // ------------------------------------------------------------------

    var editPoints = $json;
    var videoTrackIndex = $VideoTrackIndex;
    var audioTrackIndex = $AudioTrackIndex;
    var trackMode = $trackModeLiteral;

    // ------------------------------------------------------------------
    // Initialize Premiere QE API
    // ------------------------------------------------------------------

    app.enableQE();

    var qeSequence = qe.project.getActiveSequence();

    if (!qeSequence) {
        alert('Open and select the target sequence before running this script.');
        return;
    }

    // ------------------------------------------------------------------
    // Razor Helpers
    // ------------------------------------------------------------------

    // Creates razor edits on the configured video/audio tracks.
    function RazorSelectedTracks(timecode) {

        var videoTrack = qeSequence.getVideoTrackAt(videoTrackIndex);

        if (videoTrack) {
            videoTrack.razor(timecode);
        }

        var audioTrack = qeSequence.getAudioTrackAt(audioTrackIndex);

        if (audioTrack) {
            audioTrack.razor(timecode);
        }

    }

    // Creates razor edits on every video and audio track.
    function RazorAllTracks(timecode) {

        for (var index = 0; index < qeSequence.numVideoTracks; index++) {

            var videoTrack = qeSequence.getVideoTrackAt(index);

            if (videoTrack) {
                videoTrack.razor(timecode);
            }

        }

        for (var index = 0; index < qeSequence.numAudioTracks; index++) {

            var audioTrack = qeSequence.getAudioTrackAt(index);

            if (audioTrack) {
                audioTrack.razor(timecode);
            }

        }

    }

    // Routes razor requests to the appropriate implementation.
    function RazorTracks(timecode) {

        switch (trackMode) {

            case 'All':
                RazorAllTracks(timecode);
                break;

            case 'Selected':
            default:
                RazorSelectedTracks(timecode);
                break;
        }

    }

    // ------------------------------------------------------------------
    // Process Edit Points
    // ------------------------------------------------------------------

    var created = 0;

    for (var index = 0; index < editPoints.length; index++) {

        var timecode = editPoints[index];

        try {

            RazorTracks(timecode);

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

    // ------------------------------------------------------------------
    // Summary
    // ------------------------------------------------------------------

    alert(
        'PCXLab.VideoTools created ' +
        created +
        ' edit point(s). No media was removed.'
    );

}());
"@
}
