function Find-PCXBlackFrames {

    <#
    .SYNOPSIS
        Finds black frame regions in one or more media files.

    .DESCRIPTION
        Uses FFmpeg's blackdetect filter to find video regions that are
        visually black. Results are returned as PCXLab.BlackFrame objects
        for review or conversion into PCXLab.VideoSegment editing decisions.

    .PARAMETER Path
        One or more media files to analyse.

    .PARAMETER MinimumDuration
        Minimum black frame duration, in seconds.

    .PARAMETER Threshold
        Luminance threshold below which a frame is considered black.
        Range is 0.0 to 1.0.

    .EXAMPLE
        Find-PCXBlackFrames -Path 'C:\Videos\Tutorial.mp4'

    .EXAMPLE
        Get-ChildItem 'C:\Videos' -Filter *.mp4 |
            Find-PCXBlackFrames

    .OUTPUTS
        PCXLab.BlackFrame
    #>

    [CmdletBinding()]
    [OutputType('PCXLab.BlackFrame')]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('FullName')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter()]
        [ValidateRange(0.1, 3600)]
        [double]$MinimumDuration = 0.5,

        [Parameter()]
        [ValidateRange(0.0, 1.0)]
        [double]$Threshold = 0.10 # changed from 0.98

    )

    process {

        foreach ($MediaFile in $Path) {

            $VideoInfo = Get-PCXVideoInformation -Path $MediaFile

            if ($null -eq $VideoInfo -or -not $VideoInfo.HasVideo) {
                Write-Verbose "Skipping black frame detection for '$MediaFile': Media contains no video stream."
                continue
            }

            $filter = 'blackdetect=d={0}:pic_th={1}' -f $MinimumDuration, $Threshold

            $RawOutput = Invoke-PCXFFmpeg -ArgumentList @(
                '-hide_banner'
                '-nostats'
                '-i'
                $MediaFile
                '-vf'
                $filter
                '-an'
                '-f'
                'null'
                '-'
            )

            $BlackFrames = @(
                $RawOutput -split "`r?`n" |
                ConvertTo-PCXBlackFrame `
                    -SourcePath $MediaFile
            )

            Write-Verbose (
                "Detected {0} black frame region(s) in '{1}'." -f
                $BlackFrames.Count,
                $MediaFile
            )

            $BlackFrames

        }

    }

}
