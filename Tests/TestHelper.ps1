# ============================================================
# PCXLab.VideoTools Test Helper
# ============================================================

Set-StrictMode -Version Latest

$script:ModuleRoot = Resolve-Path (
    Join-Path $PSScriptRoot '..\src\Modules\PCXLab.VideoTools'
)

Import-Module $script:ModuleRoot -Force

. "$PSScriptRoot\TestData\TestData.ps1"