function Read-PCXImportDocument {

    <#
    .SYNOPSIS
        Reads and validates a PCXLab import document.

    .DESCRIPTION
        Reads a JSON document exported by a PCXLab.VideoTools
        export command and validates its structure.

    .PARAMETER Path
        Path to the JSON document.

    .PARAMETER CollectionName
        Name of the collection expected in the document.

    .OUTPUTS
        PSCustomObject
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [ValidateScript({
            Test-Path $_ -PathType Leaf
        })]
        [string]$Path,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$CollectionName

    )

    $Document = Get-Content `
        -Path $Path `
        -Raw |
        ConvertFrom-Json

    if ($null -eq $Document) {
        throw "Failed to read import document '$Path'."
    }

    if (-not $Document.PSObject.Properties['SchemaVersion']) {
        throw "Import document '$Path' does not contain SchemaVersion."
    }

    switch ($Document.SchemaVersion) {

        '1.0' {
            break
        }

        default {
            throw "Unsupported schema version '$($Document.SchemaVersion)'."
        }

    }

    if (-not $Document.PSObject.Properties[$CollectionName]) {
        throw "Import document '$Path' does not contain collection '$CollectionName'."
    }

    return $Document

}