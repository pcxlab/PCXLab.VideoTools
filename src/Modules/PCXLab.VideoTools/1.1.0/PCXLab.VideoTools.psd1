@{

    RootModule = 'PCXLab.VideoTools.psm1'

    FormatsToProcess = @(
    'PCXLab.VideoTools.Format.ps1xml'
    )

    ModuleVersion = '1.1.0'

    GUID = '11111111-1111-1111-1111-111111111111'

    Author = 'PCXLab'

    CompanyName = 'PCXLab'

    Copyright = '(c) PCXLab'

    Description = 'Professional PowerShell Video Automation Module'

    PowerShellVersion = '7.2'

    FunctionsToExport = '*'

    CmdletsToExport = @()

    VariablesToExport = @()

    AliasesToExport = @()

    PrivateData = @{

        PSData = @{

            Tags = @(
                'Video'
                'FFmpeg'
                'Automation'
                'PowerShell'
            )

            ProjectUri = ''

        }

    }

}