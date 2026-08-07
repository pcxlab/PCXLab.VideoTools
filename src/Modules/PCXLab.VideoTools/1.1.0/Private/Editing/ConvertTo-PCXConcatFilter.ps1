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
        [object]$Segment

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

        $Keep = $Segments |
            Where-Object Action -eq 'Keep'

        for ($i = 0; $i -lt $Keep.Count; $i++) {

            [void]$Builder.Append(
                "[0:v]trim=start=$($Keep[$i].StartSeconds):end=$($Keep[$i].EndSeconds),setpts=PTS-STARTPTS[v$i];"
            )

            [void]$Builder.Append(
                "[0:a]atrim=start=$($Keep[$i].StartSeconds):end=$($Keep[$i].EndSeconds),asetpts=PTS-STARTPTS[a$i];"
            )

        }

        for ($i = 0; $i -lt $Keep.Count; $i++) {

            [void]$Builder.Append("[v$i][a$i]")

        }

        [void]$Builder.Append(
            "concat=n=$($Keep.Count):v=1:a=1[outv][outa]"
        )

        return $Builder.ToString()

    }

}