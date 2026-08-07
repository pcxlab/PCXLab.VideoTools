function Get-PCXEditPointRule {

    <#
    .SYNOPSIS
        Retrieves the edit point rule for a silence classification.
    #>

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Classification

    )

    $Rules = Get-PCXSetting `
        -Name 'Analysis.EditPoints' `
        -DefaultValue @{}

        $Property = $Rules.PSObject.Properties[$Classification]

        if ($null -eq $Property) {
            return $null
        }
        
        $Rule = $Property.Value
        
        if (-not $Rule.Enabled) {
            return $null
        }
        
        return $Rule

}