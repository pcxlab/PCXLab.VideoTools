function Import-PCXSettings {

    [CmdletBinding()]
    param()

    $SettingsFile = Join-Path $PSScriptRoot '..\..\Settings.json'
    $SettingsFile = (Resolve-Path $SettingsFile).Path

    Get-Content $SettingsFile -Raw |
        ConvertFrom-Json
}