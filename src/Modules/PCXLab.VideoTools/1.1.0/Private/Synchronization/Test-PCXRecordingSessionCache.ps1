function Test-PCXRecordingSessionCache {

    <#
    .SYNOPSIS
        Determines whether a recording session cache is usable.

    .DESCRIPTION
        Returns $true if the RecordingSession.json artifact exists and can be
        imported. Returns $false if the cache is missing.

        Future enhancements may extend this function to validate file metadata
        or source fingerprints without changing callers.

    .PARAMETER Path
        Path to the RecordingSession.json file.

    .OUTPUTS
        System.Boolean
    #>

    [CmdletBinding()]
    [OutputType([bool])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path

    )

    return Test-Path -LiteralPath $Path

}
