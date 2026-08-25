function Get-PCXSetting {

    <#
    .SYNOPSIS
        Returns a setting from the module configuration.
    
    .DESCRIPTION
        Retrieves a value from the loaded Settings.json configuration
        using dot notation.
    
    .PARAMETER Name
        Setting name using dot notation.
    
    .PARAMETER DefaultValue
        Value returned when the setting does not exist.
    
    .EXAMPLE
        Get-PCXSetting -Name "Logging.Enabled"
    
    .EXAMPLE
        Get-PCXSetting -Name "Tools.FFprobe"
    
    .EXAMPLE
        Get-PCXSetting -Name "Tools.Unknown" -DefaultValue ""
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
    
        [Parameter()]
        $DefaultValue = $null
    )

    if ($null -eq $script:PCXSettings) {
        throw "Module settings have not been loaded. Call Import-PCXSettings first."
    }

    $Value = $script:PCXSettings
    
    $Value = $script:PCXSettings
    
    foreach ($Part in ($Name -split '\.')) {
        if ($null -eq $Value) {
            return $DefaultValue
        }
    
        $Property = $Value.PSObject.Properties[$Part]
    
        if ($null -eq $Property) {
            return $DefaultValue
        }
    
        $Value = $Property.Value
    }
    
    return $Value
}