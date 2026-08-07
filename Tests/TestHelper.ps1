# ============================================================
# PCXLab.VideoTools Test Helper
# ============================================================

Set-StrictMode -Version Latest

$script:ModuleRoot = Resolve-Path (
    Join-Path $PSScriptRoot '..\src\Modules\PCXLab.VideoTools\1.1.0\PCXLab.VideoTools.psd1'
)

Import-Module $script:ModuleRoot -Force

. "$PSScriptRoot\TestData\TestData.ps1"