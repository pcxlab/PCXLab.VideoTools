#Requires -Version 7.2

Set-StrictMode -Version Latest

$ModuleRoot = $PSScriptRoot

#----------------------------------------------------------
# Load Private Functions
#----------------------------------------------------------

$PrivateFolders = @(
    "Core",
    "Settings",
    "Logging",
    "Validation",
    "Utilities",
    "Converters",
    "Models",
    "Classes",
    "Providers",
    "Analysis",
    "Reports"
)

foreach ($Folder in $PrivateFolders)
{
    $Path = Join-Path $ModuleRoot "Private\$Folder"

    if (Test-Path $Path)
    {
        Get-ChildItem $Path -Filter *.ps1 -File -Recurse |
            Sort-Object FullName |
            ForEach-Object {
                . $_.FullName
            }
    }
}

#----------------------------------------------------------
# Initialize Module
#----------------------------------------------------------

Initialize-PCXVideoTools

#----------------------------------------------------------
# Load Public Functions
#----------------------------------------------------------

$PublicFunctions = foreach ($File in (Get-ChildItem (Join-Path $ModuleRoot 'Public') -Filter *.ps1 -File -Recurse | Sort-Object FullName))
{
    . $File.FullName
    $File.BaseName
}

Export-ModuleMember -Function $PublicFunctions