function Initialize-PCXVideoTools {

    <#
    .SYNOPSIS
        Initializes the PCXLab.VideoTools module.

    .DESCRIPTION
        Performs one-time module initialization when the module is imported.

    .NOTES
        Internal function.
    #>

    [CmdletBinding()]
    param()

    # Load module settings
    $script:PCXSettings = Import-PCXSettings

    # Resolve important module paths
    $versionRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $moduleRoot = Split-Path $versionRoot -Parent
    $projectRoot = Split-Path (Split-Path (Split-Path $moduleRoot -Parent) -Parent) -Parent

    # Initialize module context
    $script:PCXContext = [ordered]@{
        ModuleRoot  = $moduleRoot
        VersionRoot = $versionRoot
        ProjectRoot = $projectRoot
    }
}