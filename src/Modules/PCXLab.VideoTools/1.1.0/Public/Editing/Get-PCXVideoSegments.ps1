function Get-PCXVideoSegments {

    <#
    .SYNOPSIS
        Builds a complete video timeline from silence analysis.

    .DESCRIPTION
        Converts PCXLab.Silence objects into PCXLab.VideoSegment
        objects representing both sections to keep and sections
        to remove.

    .PARAMETER InputObject
        PCXLab.Silence object from the pipeline.

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
        [object]$InputObject

    )

    begin {

        $Silence = [System.Collections.Generic.List[object]]::new()

    }

    process {

        $supportedTypes = @(
            'PCXLab.Silence'
            'PCXLab.EditPoint'
        )

        $typeMatch = $false
        foreach ($type in $supportedTypes) {
            if ($InputObject.PSTypeNames -contains $type) {
                $typeMatch = $true
                break
            }
        }

        if (-not $typeMatch) {
            throw 'InputObject must be a PCXLab.Silence or PCXLab.EditPoint object.'
        }

        $Silence.Add($InputObject)

    }

    end {

        $Segments = [System.Collections.Generic.List[object]]::new()

        if ($Silence.Count -eq 0) {
            return
        }

        $uniqueSourcePaths = $Silence.SourcePath | Sort-Object -Unique

        if ($uniqueSourcePaths.Count -gt 1) {
            throw "All input objects must belong to the same source. Found: $($uniqueSourcePaths -join ', ')."
        }

        $SourcePath = $Silence[0].SourcePath

        $VideoDuration = Get-PCXVideoDuration `
            -Path $SourcePath

        $CurrentPosition = [TimeSpan]::Zero

        foreach ($Item in ($Silence | Sort-Object Start)) {

            #
            # KEEP
            #

            if ($Item.Start -gt $CurrentPosition) {

                $Segment = Add-PCXKeepSegment `
                    -SourcePath $SourcePath `
                    -Start $CurrentPosition `
                    -End $Item.Start

                if ($null -ne $Segment) {
                    $Segments.Add($Segment)
                }

            }

            #
            # REMOVE
            #

            $Segment = Add-PCXRemoveSegment `
                -SourcePath $SourcePath `
                -Start $Item.Start `
                -End $Item.End

            if ($null -ne $Segment) {
                $Segments.Add($Segment)
            }

            $CurrentPosition = $Item.End

        }

        #
        # Final KEEP segment
        #

        if ($CurrentPosition -lt $VideoDuration) {

            $Segment = Add-PCXKeepSegment `
                -SourcePath $SourcePath `
                -Start $CurrentPosition `
                -End $VideoDuration

            if ($null -ne $Segment) {
                $Segments.Add($Segment)
            }

        }

        $Segments | 
            Optimize-PCXVideoSegments

    }

}