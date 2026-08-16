function Test-PCXVideoTools {

    <#
    .SYNOPSIS
        Tests the PCXLab.VideoTools module installation.

    .DESCRIPTION
        Verifies that the module has been initialized correctly,
        settings are loaded, and required external tools can
        be located.

    .OUTPUTS
        PSCustomObject
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    $Context = Get-PCXContext
    $Module = Get-Module -Name PCXLab.VideoTools

    #$FFprobe = Get-PCXToolPath -Name "FFprobe"
    $FFprobe = Get-PCXToolPath -Tool FFprobe

    [PSCustomObject]@{

        Module            = $Module.Name
        Version           = $Module.Version.ToString()
        PowerShellVersion = $PSVersionTable.PSVersion.ToString()

        SettingsLoaded    = $null -ne (Get-PCXSetting -Name "Logging")

        FFprobeFound      = $null -ne $FFprobe
        FFprobePath       = $FFprobe

        ModuleRoot        = $Context.ModuleRoot
        VersionRoot       = $Context.VersionRoot
        ProjectRoot       = $Context.ProjectRoot
    }
}