function Resolve-PCXLinkedMediaSources {

    <#
    .SYNOPSIS
        Resolves linked media source relationships for a collection of sources.

    .DESCRIPTION
        Scans the supplied media sources for the known '.webcam.mp4' naming
        convention. When a webcam source is found, it is linked to the
        matching primary screen recording that shares the same filename
        prefix (everything before '.webcam.mp4').

        The relationship is recorded on the webcam source's LinkedSourceId
        property using the primary source's Id. The primary source is not
        modified.

        Discovery is based on the source Path / filename, not on Id, so
        callers that supply custom Id values continue to work correctly.

        If a matching primary source cannot be found, the webcam source is
        left unchanged.

    .PARAMETER MediaSources
        Collection of PCXLab.MediaSource objects to resolve in-place.

    .OUTPUTS
        None. The input collection is modified in-place.
    #>

    [CmdletBinding()]
    [OutputType([void])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Collections.Generic.IList[object]]$MediaSources

    )

    if ($MediaSources.Count -eq 0) {
        return
    }

    $sourceByFileName = @{}

    foreach ($source in $MediaSources) {

        if ($source.PSTypeNames -notcontains 'PCXLab.MediaSource') {
            throw 'MediaSources must contain PCXLab.MediaSource objects.'
        }

        $fileName = [System.IO.Path]::GetFileName($source.Path)
        $sourceByFileName[$fileName] = $source

    }

    foreach ($source in $MediaSources) {

        if (-not [string]::IsNullOrWhiteSpace($source.LinkedSourceId)) {
            continue
        }

        $webcamFileName = [System.IO.Path]::GetFileName($source.Path)

        if ($webcamFileName -notlike '*.webcam.mp4') {
            continue
        }

        $primaryFileName = $webcamFileName -replace '\.webcam\.mp4$'

        if ([string]::IsNullOrWhiteSpace($primaryFileName)) {
            continue
        }

        $linkedSource = $sourceByFileName[$primaryFileName]

        if ($null -eq $linkedSource) {
            continue
        }

        $source.LinkedSourceId = $linkedSource.Id

    }

}
