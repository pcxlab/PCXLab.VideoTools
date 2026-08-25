function Get-PCXRecordingSessionPath {

    <#
    .SYNOPSIS
        Returns the path to the RecordingSession.json artifact for a set of media sources.

    .DESCRIPTION
        Resolves the default location of the persistent recording session cache.
        The cache is stored beside the first source using the filename
        RecordingSession.json.

    .PARAMETER Sources
        PCXLab.MediaSource objects participating in the recording session.

    .OUTPUTS
        System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object[]]$Sources

    )

    if ($Sources.Count -eq 0) {
        throw 'At least one media source is required to resolve a recording session path.'
    }

    $FirstSource = $Sources[0]

    if ($FirstSource.PSTypeNames -notcontains 'PCXLab.MediaSource') {
        throw 'Sources must be PCXLab.MediaSource objects.'
    }

    return Get-PCXArtifactPath `
        -SourcePath $FirstSource.Path `
        -ArtifactType RecordingSession

}
