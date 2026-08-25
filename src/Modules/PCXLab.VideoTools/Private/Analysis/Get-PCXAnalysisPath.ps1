function Get-PCXAnalysisPath {

    <#
    .SYNOPSIS
        Returns the path to the Analysis.json artifact for a media file.

    .DESCRIPTION
        Resolves the default location of the persistent analysis cache.
        The cache is stored beside the source using the filename
        <SourceName>-Analysis.json.

    .PARAMETER SourcePath
        Source media file.

    .OUTPUTS
        System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath

    )

    return Get-PCXDefaultOutputPath `
        -SourcePath $SourcePath `
        -Suffix 'Analysis' `
        -Extension '.json'

}
