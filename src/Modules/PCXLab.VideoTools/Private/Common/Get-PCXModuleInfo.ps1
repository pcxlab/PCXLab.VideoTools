function Get-PCXModuleInfo {

    <#
    .SYNOPSIS
        Returns information about the loaded PCXLab.VideoTools module.

    .OUTPUTS
        PCXLab.ModuleInfo
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    $Module = Get-Module -Name 'PCXLab.VideoTools'

    if ($null -eq $Module)
    {
        throw 'PCXLab.VideoTools module is not loaded.'
    }

    [PSCustomObject]@{

        PSTypeName = 'PCXLab.ModuleInfo'

        Name            = $Module.Name
        Version         = $Module.Version.ToString()
        ModuleBase      = $Module.ModuleBase
        ModuleType      = $Module.ModuleType.ToString()
        Path            = $Module.Path
        Guid            = $Module.Guid
        Author          = $Module.Author
        CompanyName     = $Module.CompanyName
        Description     = $Module.Description
        PowerShellVersion = $Module.PowerShellVersion

    }

}