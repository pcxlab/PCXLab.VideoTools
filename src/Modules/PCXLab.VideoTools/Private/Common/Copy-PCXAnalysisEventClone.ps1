function Copy-PCXAnalysisEventClone {

    <#
    .SYNOPSIS
        Creates a shallow clone of an analysis event, preserving all properties and type names.

    .DESCRIPTION
        Copies every NoteProperty and custom PSTypeName from the source analysis event
        into a new PSCustomObject. This is the canonical helper for constructing
        projected clones during timeline mapping operations.

    .PARAMETER InputObject
        The analysis event to clone.

    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$InputObject

    )

    $clone = [PSCustomObject]@{ }

    $clone.PSObject.TypeNames.Clear()

    foreach ($tn in $InputObject.PSTypeNames) {
        $clone.PSObject.TypeNames.Add($tn)
    }

    foreach ($prop in $InputObject.PSObject.Properties) {
        $clone | Add-Member -NotePropertyName $prop.Name -NotePropertyValue $prop.Value -Force
    }

    return $clone

}
