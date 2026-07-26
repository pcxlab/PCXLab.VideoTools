# ============================================================
# PCXLab.VideoTools Test Data
# ============================================================

$script:TestDataPath = $PSScriptRoot

$script:TestVideo = Join-Path $script:TestDataPath 'Test.mp4'

if (-not (Test-Path $script:TestVideo)) {
    throw "Test video not found: $script:TestVideo"
}