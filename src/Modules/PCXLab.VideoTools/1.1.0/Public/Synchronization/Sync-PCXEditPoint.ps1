function Sync-PCXEditPoint {

    <#
    .SYNOPSIS
        Translates reference edit points to equivalent edit points for synchronized sources.

    .DESCRIPTION
        Accepts edit decisions expressed on the reference recording and emits
        equivalent PCXLab.EditPoint objects for every other synchronized source
        using the offsets stored in a RecordingSession.json cache.

    .PARAMETER InputObject
        PCXLab.EditPoint object from the pipeline.

    .PARAMETER RecordingSession
        Path to a RecordingSession.json file or an imported PCXLab.MediaSynchronization object.

    .EXAMPLE
        $EditPoints | Sync-PCXEditPoint -RecordingSession 'C:\Videos\RecordingSession.json'

    .OUTPUTS
        PCXLab.EditPoint
    #>

    [CmdletBinding()]
    [OutputType('PCXLab.EditPoint')]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [ValidateNotNull()]
        [object]$InputObject,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [object]$RecordingSession

    )

    begin {

        if ($RecordingSession -is [string]) {

            $Session = Import-PCXRecordingSession -Path $RecordingSession

        }
        elseif ($RecordingSession.PSTypeNames -contains 'PCXLab.MediaSynchronization') {

            $Session = $RecordingSession

        }
        else {

            throw 'RecordingSession must be a path to a RecordingSession.json file or a PCXLab.MediaSynchronization object.'

        }

    }

    process {

        if ($InputObject.PSTypeNames -notcontains 'PCXLab.EditPoint') {
            throw 'InputObject must be a PCXLab.EditPoint object.'
        }

        if ($null -eq $Session.Timeline.SourceOffsets) {
            return
        }

        foreach ($SourceOffset in $Session.Timeline.SourceOffsets) {

            Convert-PCXEditPointToSource `
                -EditPoint $InputObject `
                -SourceOffset $SourceOffset

        }

    }

}
