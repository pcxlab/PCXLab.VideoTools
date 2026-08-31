function Convert-PCXAnalysisEventToEdited {

    <#
    .SYNOPSIS
        Projects analysis events onto an edited timeline using a TimelineMap.

    .DESCRIPTION
        Generic, contract-driven projection engine that transforms analysis events
        conforming to Test-PCXAnalysisEvent from original timeline coordinates
        to edited timeline coordinates using a PCXLab.TimelineMap.

        - Range events falling entirely within removed segments are discarded.
        - Range events overlapping kept segments are mapped and clamped.
        - Point events falling within kept segments are shifted to edited coordinates.
        - All payload properties and type names are preserved transparently without
          type-switching or event-specific branching.

    .PARAMETER InputObject
        One or more analysis events satisfying Test-PCXAnalysisEvent.

    .PARAMETER TimelineMap
        A PCXLab.TimelineMap object describing kept timeline intervals.

    .OUTPUTS
        System.Object
    #>

    [CmdletBinding()]
    param(

        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()]
        [object]$InputObject,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$TimelineMap

    )

    begin {

        if ($TimelineMap.PSTypeNames -notcontains 'PCXLab.TimelineMap') {
            throw 'TimelineMap must be a PCXLab.TimelineMap object.'
        }

        $events = [System.Collections.Generic.List[object]]::new()

    }

    process {

        if (Test-PCXAnalysisEvent -InputObject $InputObject) {
            $events.Add($InputObject)
        }
        else {
            throw "InputObject must conform to the PCXLab analysis event contract."
        }

    }

    end {

        foreach ($event in $events) {

            $mStart = [double]$event.StartSeconds
            $mEnd = [double]$event.EndSeconds
            $isPoint = ($mStart -eq $mEnd)

            foreach ($interval in $TimelineMap.Intervals) {

                $iStart = [double]$interval.OriginalStartSeconds
                $iEnd = [double]$interval.OriginalEndSeconds
                $eStart = [double]$interval.EditedStartSeconds

                if ($isPoint) {

                    if ($mStart -ge $iStart -and $mStart -le $iEnd) {

                        $pStart = [Math]::Round(($eStart + ($mStart - $iStart)), 3)

                        $clone = Copy-PCXAnalysisEventClone -InputObject $event

                        $clone.Start = [TimeSpan]::FromSeconds($pStart)
                        $clone.End = [TimeSpan]::FromSeconds($pStart)
                        $clone.Duration = [TimeSpan]::Zero
                        $clone.StartSeconds = $pStart
                        $clone.EndSeconds = $pStart
                        $clone.DurationSeconds = 0.0

                        $clone

                    }

                }
                else {

                    $overlapStart = [Math]::Max($mStart, $iStart)
                    $overlapEnd = [Math]::Min($mEnd, $iEnd)

                    if ($overlapStart -lt $overlapEnd) {

                        $pStart = [Math]::Round(($eStart + ($overlapStart - $iStart)), 3)
                        $pEnd = [Math]::Round(($eStart + ($overlapEnd - $iStart)), 3)
                        $pDur = [Math]::Round(($pEnd - $pStart), 3)

                        $clone = Copy-PCXAnalysisEventClone -InputObject $event

                        $clone.Start = [TimeSpan]::FromSeconds($pStart)
                        $clone.End = [TimeSpan]::FromSeconds($pEnd)
                        $clone.Duration = [TimeSpan]::FromSeconds($pDur)
                        $clone.StartSeconds = $pStart
                        $clone.EndSeconds = $pEnd
                        $clone.DurationSeconds = $pDur

                        $clone

                    }

                }

            }

        }

    }

}
