function Optimize-PCXVideoSegments {

    <#
    .SYNOPSIS
        Optimizes a collection of video segments.

    .DESCRIPTION
        Cleans a timeline before it is consumed by editing commands.

        Current optimizations:

        • Removes zero-length segments
        • Removes segments shorter than the minimum duration
        • Merges adjacent segments with the same action
        • Sorts the timeline

    .PARAMETER InputObject
        Video segment from the pipeline.

    .PARAMETER MinimumDuration
        Minimum segment duration.

    .OUTPUTS
        PCXLab.VideoSegment
    #>

    [CmdletBinding()]
    [OutputType('PCXLab.VideoSegment')]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [ValidateNotNull()]
        [object]$InputObject,

        [Parameter()]
        [TimeSpan]$MinimumDuration = (
            [TimeSpan]::FromMilliseconds(250)
        )

    )

    begin {

        $Segments = [System.Collections.Generic.List[object]]::new()

    }

    process {

        if ($InputObject.PSTypeNames -notcontains 'PCXLab.VideoSegment') {
            throw 'InputObject must be a PCXLab.VideoSegment object.'
        }

        $Segments.Add($InputObject)

    }

    end {

        $Timeline = $Segments |
        Sort-Object Start |
        Where-Object {
            $_.Duration -ge $MinimumDuration
        }

        if (-not $Timeline) {
            return
        }

        $Previous = $Timeline[0]

        for ($i = 1; $i -lt $Timeline.Count; $i++) {

            $Current = $Timeline[$i]

            if ($Previous.Action -eq $Current.Action) {

                $Previous = New-PCXVideoSegmentObject `
                    -SourcePath $Previous.SourcePath `
                    -Start $Previous.Start `
                    -End $Current.End `
                    -Action $Previous.Action

                continue

            }

            $Previous

            $Previous = $Current

        }

        $Previous

    }

}