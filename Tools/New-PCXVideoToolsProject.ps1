#Requires -Version 7.0
<#
.SYNOPSIS
    Creates the initial PCXLab.VideoTools project structure.

.DESCRIPTION
    Bootstraps the folder structure and placeholder files for the
    PCXLab.VideoTools PowerShell module.

.EXAMPLE
    .\New-PCXVideoToolsProject.ps1

.EXAMPLE
    .\New-PCXVideoToolsProject.ps1 -RootPath "C:\Projects"
#>

[CmdletBinding()]
param
(
    [string]$RootPath = (Get-Location).Path,

    [string]$ModuleName = "PCXLab.VideoTools",

    [string]$Version = "1.0.0"
)

$ProjectRoot = Join-Path $RootPath $ModuleName
$ModuleRoot  = Join-Path $ProjectRoot "src\Modules\$ModuleName\$Version"

Write-Host ""
Write-Host "Creating project..." -ForegroundColor Cyan
Write-Host $ProjectRoot -ForegroundColor Yellow
Write-Host ""

#------------------------------------------------------------
# Folder Structure
#------------------------------------------------------------

$Folders = @(

".github",
".github\workflows",

"Build",

"Docs",
"Docs\ADR",
"Docs\Architecture",
"Docs\Images",

"Samples",

"Tests",
"Tests\Public",
"Tests\Private",
"Tests\Integration",
"Tests\TestData",

"Tools",
"Tools\FFmpeg",
"Tools\FFprobe",
"Tools\MediaInfo",
"Tools\Whisper",

"src",
"src\Modules",
"src\Modules\$ModuleName",
"src\Modules\$ModuleName\$Version",

"src\Modules\$ModuleName\$Version\Public",
"src\Modules\$ModuleName\$Version\Public\Analysis",
"src\Modules\$ModuleName\$Version\Public\Editing",
"src\Modules\$ModuleName\$Version\Public\Export",
"src\Modules\$ModuleName\$Version\Public\Reports",
"src\Modules\$ModuleName\$Version\Public\Utilities",

"src\Modules\$ModuleName\$Version\Private",
"src\Modules\$ModuleName\$Version\Private\Analysis",
"src\Modules\$ModuleName\$Version\Private\Classes",
"src\Modules\$ModuleName\$Version\Private\Converters",
"src\Modules\$ModuleName\$Version\Private\Core",
"src\Modules\$ModuleName\$Version\Private\Logging",
"src\Modules\$ModuleName\$Version\Private\Models",
"src\Modules\$ModuleName\$Version\Private\Parsing",

"src\Modules\$ModuleName\$Version\Private\Providers",
"src\Modules\$ModuleName\$Version\Private\Providers\FFmpeg",
"src\Modules\$ModuleName\$Version\Private\Providers\FFprobe",
"src\Modules\$ModuleName\$Version\Private\Providers\MediaInfo",
"src\Modules\$ModuleName\$Version\Private\Providers\Whisper",

"src\Modules\$ModuleName\$Version\Private\Reports",
"src\Modules\$ModuleName\$Version\Private\Resources",
"src\Modules\$ModuleName\$Version\Private\Schemas",
"src\Modules\$ModuleName\$Version\Private\Settings",
"src\Modules\$ModuleName\$Version\Private\Utilities",
"src\Modules\$ModuleName\$Version\Private\Validation",

"src\Modules\$ModuleName\$Version\en-US"
)

foreach ($Folder in $Folders)
{
    $Path = Join-Path $ProjectRoot $Folder

    if (-not (Test-Path $Path))
    {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Host "Created Folder : $Folder"
    }
}

#------------------------------------------------------------
# Files
#------------------------------------------------------------

$Files = @(

".gitignore",
"README.md",
"LICENSE",

"Build\Build.ps1",
"Build\BuildSettings.psd1",
"Build\Release.ps1",
"Build\README.md",

"Docs\README.md",

"Docs\Architecture\ModuleArchitecture.md",
"Docs\Architecture\CodingStandards.md",
"Docs\Architecture\ObjectModel.md",
"Docs\Architecture\ProviderArchitecture.md",
"Docs\Architecture\Logging.md",
"Docs\Architecture\Settings.md",
"Docs\Architecture\ErrorHandling.md",
"Docs\Architecture\Versioning.md",

"Docs\ADR\ADR-0001-ModuleArchitecture.md",
"Docs\ADR\ADR-0002-CodingStandards.md",
"Docs\ADR\ADR-0003-Logging.md",
"Docs\ADR\ADR-0004-Settings.md",
"Docs\ADR\ADR-0005-ErrorHandling.md",
"Docs\ADR\ADR-0006-ObjectModel.md",
"Docs\ADR\ADR-0007-Providers.md",
"Docs\ADR\ADR-0008-Versioning.md",

"Samples\README.md",
"Samples\AnalyzeVideo.ps1",
"Samples\BatchAnalysis.ps1",
"Samples\ExportMarkers.ps1",

"Tests\README.md",
"Tests\PesterConfiguration.psd1",

"Tools\README.md",

".github\workflows\build.yml",

"src\Modules\$ModuleName\$Version\README.md",
"src\Modules\$ModuleName\$Version\CHANGELOG.md",
"src\Modules\$ModuleName\$Version\LICENSE.txt",
"src\Modules\$ModuleName\$Version\Settings.json",

"src\Modules\$ModuleName\$Version\$ModuleName.psd1",
"src\Modules\$ModuleName\$Version\$ModuleName.psm1",

"src\Modules\$ModuleName\$Version\Public\README.md",
"src\Modules\$ModuleName\$Version\Private\README.md",
"src\Modules\$ModuleName\$Version\Private\Providers\README.md",

"src\Modules\$ModuleName\$Version\en-US\about_$ModuleName.help.txt"
)

foreach ($File in $Files)
{
    $Path = Join-Path $ProjectRoot $File

    if (-not (Test-Path $Path))
    {
        New-Item -ItemType File -Path $Path -Force | Out-Null
        Write-Host "Created File   : $File"
    }
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host " PCXLab.VideoTools project created successfully"
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Location:"
Write-Host $ProjectRoot -ForegroundColor Yellow
Write-Host ""