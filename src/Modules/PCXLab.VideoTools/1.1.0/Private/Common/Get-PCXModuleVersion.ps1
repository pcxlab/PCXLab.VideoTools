function Get-PCXModuleVersion {

    [CmdletBinding()]
    [OutputType([string])]
    param()

    (Get-PCXModuleInfo).Version

}