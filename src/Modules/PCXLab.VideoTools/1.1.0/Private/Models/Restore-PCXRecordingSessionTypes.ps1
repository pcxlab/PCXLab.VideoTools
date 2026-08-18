function Restore-PCXRecordingSessionTypes {

    <#
    .SYNOPSIS
        Restores custom PCXLab type names after importing a recording session JSON.

    .DESCRIPTION
        ConvertFrom-Json returns PSCustomObject instances and removes custom
        PSTypeNames. This function restores all nested PCXLab types so imported
        recording session objects behave exactly like freshly generated
        recording session objects.

    .PARAMETER InputObject
        PCXLab.MediaSynchronization object.

    .OUTPUTS
        PCXLab.MediaSynchronization
    #>

    [CmdletBinding()]
    [OutputType('PCXLab.MediaSynchronization')]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$InputObject

    )

    #
    # MediaSynchronization
    #

    if ($InputObject.PSTypeNames -notcontains 'PCXLab.MediaSynchronization') {

        $InputObject.PSObject.TypeNames.Insert(
            0,
            'PCXLab.MediaSynchronization'
        )

    }

    #
    # Sources
    #

    if ($null -ne $InputObject.Sources) {

        foreach ($Source in $InputObject.Sources) {

            if ($Source.PSTypeNames -notcontains 'PCXLab.MediaSource') {

                $Source.PSObject.TypeNames.Insert(
                    0,
                    'PCXLab.MediaSource'
                )

            }

            #
            # MediaInformation
            #

            if ($null -ne $Source.MediaInformation) {

                if ($Source.MediaInformation.PSTypeNames -notcontains 'PCXLab.MediaInformation') {

                    $Source.MediaInformation.PSObject.TypeNames.Insert(
                        0,
                        'PCXLab.MediaInformation'
                    )

                }

            }

            if (-not $Source.PSObject.Properties['SynchronizationMethod']) {
                $Source | Add-Member -NotePropertyName 'SynchronizationMethod' -NotePropertyValue 'Auto'
            }

            if (-not $Source.PSObject.Properties['AnalysisMode']) {
                $Source | Add-Member -NotePropertyName 'AnalysisMode' -NotePropertyValue 'Auto'
            }

            if (-not $Source.PSObject.Properties['RenderingMode']) {
                $Source | Add-Member -NotePropertyName 'RenderingMode' -NotePropertyValue 'Auto'
            }

            if (-not $Source.PSObject.Properties['LinkedSourceId']) {
                $Source | Add-Member -NotePropertyName 'LinkedSourceId' -NotePropertyValue $null
            }

        }

    }

    #
    # Timeline
    #

    if ($null -ne $InputObject.Timeline) {

        if ($InputObject.Timeline.PSTypeNames -notcontains 'PCXLab.SynchronizationTimeline') {

            $InputObject.Timeline.PSObject.TypeNames.Insert(
                0,
                'PCXLab.SynchronizationTimeline'
            )

        }

        #
        # Restore TimeSpan properties
        #

        $InputObject.Timeline.TotalDuration = [TimeSpan]::FromTicks(
            [Int64]$InputObject.Timeline.TotalDuration.Ticks
        )

        #
        # SourceOffsets
        #

        if ($null -ne $InputObject.Timeline.SourceOffsets) {

            foreach ($Offset in $InputObject.Timeline.SourceOffsets) {

                if ($Offset.PSTypeNames -notcontains 'PCXLab.SourceOffset') {

                    $Offset.PSObject.TypeNames.Insert(
                        0,
                        'PCXLab.SourceOffset'
                    )

                }

            }

        }

        #
        # Segments
        #

        if ($null -ne $InputObject.Timeline.Segments) {

            foreach ($Segment in $InputObject.Timeline.Segments) {

                if ($Segment.PSTypeNames -notcontains 'PCXLab.SynchronizationSegment') {

                    $Segment.PSObject.TypeNames.Insert(
                        0,
                        'PCXLab.SynchronizationSegment'
                    )

                }

                #
                # Contributions
                #

                if ($null -ne $Segment.Contributions) {

                    foreach ($Contribution in $Segment.Contributions) {

                        if ($Contribution.PSTypeNames -notcontains 'PCXLab.SynchronizationContribution') {

                            $Contribution.PSObject.TypeNames.Insert(
                                0,
                                'PCXLab.SynchronizationContribution'
                            )

                        }

                    }

                }

            }

        }

    }

    return $InputObject

}
