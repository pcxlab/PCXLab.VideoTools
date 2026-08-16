function Build-PCXMediaSourcesFromPaths {

    <#
    .SYNOPSIS
        Converts file paths into PCXLab.MediaSource objects for the legacy
        path-based Edit-PCXRecordingSession workflow.

    .DESCRIPTION
        Legacy compatibility helper that builds MediaSource objects from the
        reference path and source paths used by the original path-based API.

        It preserves today's behavior for existing scripts, including the
        known Bandicam webcam recording pattern where a video-only companion
        file named 'bandicam.webcam.mp4' is treated as starting at the same
        time as the reference (OffsetHint = 0).

        This helper is intentionally separate from the synchronization engine
        and is used only by the legacy Path parameter set of
        Edit-PCXRecordingSession. New callers should construct MediaSource
        objects explicitly and use the MediaSource parameter set.

    .PARAMETER ReferencePath
        Path to the reference media file.

    .PARAMETER SourcePaths
        Paths to the other media files in the recording session.

    .OUTPUTS
        PCXLab.MediaSource[]
    #>

    [CmdletBinding()]
    [OutputType([object[]])]
    param(

        [Parameter(Mandatory)]
        [ValidateScript({
                Test-Path -LiteralPath $_ -PathType Leaf
            })]
        [string]$ReferencePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$SourcePaths

    )

    $MediaSources = [System.Collections.Generic.List[object]]::new()

    $ReferenceSource = New-PCXMediaSource -Path $ReferencePath
    $MediaSources.Add($ReferenceSource)

    foreach ($MediaPath in $SourcePaths) {

        $FileName = [System.IO.Path]::GetFileName($MediaPath)

        if ($FileName -eq 'bandicam.webcam.mp4') {

            $source = New-PCXMediaSource `
                -Path $MediaPath `
                -SynchronizationMethod 'OffsetHint' `
                -OffsetHint 0

        }
        else {

            $source = New-PCXMediaSource -Path $MediaPath

        }

        $MediaSources.Add($source)

    }

    return $MediaSources.ToArray()

}
