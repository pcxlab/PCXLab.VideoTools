function ConvertTo-PCXConcatFilter {

    <#
    .SYNOPSIS
        Creates an FFmpeg filter graph for keeping video segments.

    .DESCRIPTION
        Builds an FFmpeg filter_complex string from
        PCXLab.VideoSegment objects.

    .PARAMETER Segment
        Video segments received from the pipeline.

    .OUTPUTS
        System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [ValidateNotNull()]
        [object]$Segment,

        [Parameter()]
        [ValidateRange(0, 100)]
        [int]$InputIndex = 0,

        [Parameter()]
        [switch]$HasAudio = $true

    )

    begin {

        $Segments = [System.Collections.Generic.List[object]]::new()

    }

    process {

        if ($Segment.PSTypeNames -notcontains 'PCXLab.VideoSegment') {
            throw 'InputObject must be a PCXLab.VideoSegment object.'
        }

        $Segments.Add($Segment)

    }

    end {

        $Builder = [System.Text.StringBuilder]::new()

        if ($Segments.Count -eq 0) {
            throw 'No video segments were supplied.'
        }

        $Keep = $Segments |
        Where-Object Action -eq 'Keep'

        if ($Keep.Count -eq 0) {
            throw 'No Keep segments were found.'
        }

        for ($i = 0; $i -lt $Keep.Count; $i++) {

            [void]$Builder.Append(
                "[$InputIndex`:v]trim=start=$($Keep[$i].StartSeconds):end=$($Keep[$i].EndSeconds),setpts=PTS-STARTPTS[v$i];"

            )

            if ($HasAudio) {
                [void]$Builder.Append(
                    "[$InputIndex`:a]atrim=start=$($Keep[$i].StartSeconds):end=$($Keep[$i].EndSeconds),asetpts=PTS-STARTPTS[a$i];"
                )
            }

        }

        for ($i = 0; $i -lt $Keep.Count; $i++) {

            if ($HasAudio) {
                [void]$Builder.Append("[v$i][a$i]")
            }
            else {
                [void]$Builder.Append("[v$i]")
            }

        }

        if ($HasAudio) {
            [void]$Builder.Append(
                "concat=n=$($Keep.Count):v=1:a=1[outv][outa]"
            )
        }
        else {
            [void]$Builder.Append(
                "concat=n=$($Keep.Count):v=1:a=0[outv]"
            )
        }

        return $Builder.ToString()

    }

}