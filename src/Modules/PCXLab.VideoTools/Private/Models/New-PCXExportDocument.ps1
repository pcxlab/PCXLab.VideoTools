function New-PCXExportDocument {

    <#
    .SYNOPSIS
        Creates a standard export document.

    .DESCRIPTION
        Creates the common document structure used by all export
        commands in PCXLab.VideoTools.

    .PARAMETER CollectionName
        Name of the collection property.

    .PARAMETER Items
        Objects to include in the collection.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$CollectionName,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object[]]$Items

    )

    $Document = [ordered]@{

        SchemaVersion = '1.0'

        ModuleVersion = Get-PCXModuleVersion

        GeneratedOn = Get-Date

    }

    $Document[$CollectionName] = $Items

    return [PSCustomObject]$Document

}