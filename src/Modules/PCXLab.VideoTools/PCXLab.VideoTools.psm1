#Requires -Version 7.2

Set-StrictMode -Version Latest

$ModuleRoot = $PSScriptRoot

#----------------------------------------------------------
# Load Private Functions
#----------------------------------------------------------

$PrivateFiles = Get-ChildItem -Path (Join-Path $ModuleRoot 'Private') -Recurse -Filter '*.ps1' -File |
    Sort-Object FullName

# Load Common helpers first so other private functions can depend on them.
$CommonFiles = $PrivateFiles | Where-Object { $_.Directory.Name -eq 'Common' }
$OtherFiles = $PrivateFiles | Where-Object { $_.Directory.Name -ne 'Common' }

foreach ($File in @($CommonFiles) + @($OtherFiles)) {
    . $File.FullName
}

#----------------------------------------------------------
# Initialize Module
#----------------------------------------------------------

Initialize-PCXVideoTools

#----------------------------------------------------------
# Load Public Functions
#----------------------------------------------------------

$PublicFunctions = Get-ChildItem -Path (Join-Path $ModuleRoot 'Public') -Recurse -Filter '*.ps1' -File |
    Sort-Object FullName |
    ForEach-Object {

        . $_.FullName

        $_.BaseName

    }

#----------------------------------------------------------
# Export Public Functions
#----------------------------------------------------------

Export-ModuleMember -Function $PublicFunctions