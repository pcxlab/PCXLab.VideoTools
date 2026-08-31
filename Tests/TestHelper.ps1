# ============================================================
# PCXLab.VideoTools Test Helper
# ============================================================

Set-StrictMode -Version Latest

# ============================================================
# Repository
# ============================================================

$script:RepositoryRoot = Resolve-Path (
    Join-Path $PSScriptRoot '..'
)

# ============================================================
# Module
# ============================================================

$script:ModuleRoot = Resolve-Path (
    Join-Path $script:RepositoryRoot 'src\Modules\PCXLab.VideoTools\PCXLab.VideoTools.psd1'
)

Import-Module $script:ModuleRoot -Force

# ============================================================
# Sample Media
# ============================================================

$script:MediaSamplesRoot = Join-Path $script:RepositoryRoot 'MediaSamples'

# Single-source sample
$script:SingleSourceVideo = Join-Path $script:MediaSamplesRoot 'SingleSource\DesktopScreen.mp4'

# Backward compatibility for existing tests
$script:TestVideo = $script:SingleSourceVideo

# Multi-source samples
$script:DesktopScreenVideo = Join-Path $script:MediaSamplesRoot 'MultiSource\DesktopScreen.mp4'
$script:WebcamVideo        = Join-Path $script:MediaSamplesRoot 'MultiSource\Webcam.mp4'
$script:MobileFaceVideo    = Join-Path $script:MediaSamplesRoot 'MultiSource\MobileFace.mp4'

# ============================================================
# Validate Sample Media
# ============================================================

foreach ($path in @(
    $script:SingleSourceVideo,
    $script:DesktopScreenVideo,
    $script:WebcamVideo,
    $script:MobileFaceVideo
)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Required test media not found: $path"
    }
}