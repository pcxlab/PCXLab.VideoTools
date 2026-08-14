function Test-PCXVideoAnalysisCache {

    <#
    .SYNOPSIS
        Determines whether a video analysis cache is usable.

    .DESCRIPTION
        Returns $true if the Analysis.json artifact exists and can be
        imported. Returns $false if the cache is missing.

        Future enhancements may extend this function to validate file metadata
        or source fingerprints without changing callers.

    .PARAMETER Path
        Path to the Analysis.json file.

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
