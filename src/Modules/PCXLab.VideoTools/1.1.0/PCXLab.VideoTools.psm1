#Requires -Version 7.2

Set-StrictMode -Version Latest

$ModuleRoot = $PSScriptRoot

#----------------------------------------------------------
# Load Private Functions
#----------------------------------------------------------

Get-ChildItem -Path (Join-Path $ModuleRoot 'Private') -Recurse -Filter '*.ps1' -File |
    Sort-Object FullName |
    ForEach-Object {
        . $_.FullName
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