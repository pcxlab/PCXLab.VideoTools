# ============================================================
# Profile-SynchronizationPipeline.ps1
# Profiling script to measure execution timing of Stage 1 (audio activity),
# Stage 2A (correlation search), Stage 3A (confidence scoring), and total pipeline time.
# ============================================================

[CmdletBinding()]
param(
    [string]$MediaPath
)

Set-StrictMode -Version Latest

# Import module
$ModuleManifest = Join-Path $PSScriptRoot '..\src\Modules\PCXLab.VideoTools\PCXLab.VideoTools.psd1'

Import-Module $ModuleManifest -Force
$script:Module = Get-Module PCXLab.VideoTools

# Resolve test video if not specified
if ([string]::IsNullOrWhiteSpace($MediaPath)) {
    $MediaPath = Resolve-Path (Join-Path $PSScriptRoot '..\Tests\TestData\Test.mp4')
}

if (-not (Test-Path -LiteralPath $MediaPath)) {
    throw "Test video file not found: $MediaPath"
}

Write-Host "Profiling synchronization pipeline using: $MediaPath" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$totalSw = [System.Diagnostics.Stopwatch]::StartNew()

# 1. Measure Stage 1: Get-PCXAudioActivity (Reference & Comparison)
$stage1Sw = [System.Diagnostics.Stopwatch]::StartNew()
$refTimeline = & $script:Module { param($p) Get-PCXAudioActivity -Path $p } $MediaPath
$compTimeline = & $script:Module { param($p) Get-PCXAudioActivity -Path $p } $MediaPath
$stage1Sw.Stop()

# 2. Measure Stage 2A: Search-PCXAudioCorrelation
$stage2Sw = [System.Diagnostics.Stopwatch]::StartNew()
$correlationResult = & $script:Module {
    param($ref, $comp)
    Search-PCXAudioCorrelation -ReferenceTimeline $ref -ComparisonTimeline $comp
} $refTimeline $compTimeline
$stage2Sw.Stop()

# 3. Measure Stage 3A: Measure-PCXCorrelationConfidence
$stage3Sw = [System.Diagnostics.Stopwatch]::StartNew()
$confidence = & $script:Module {
    param($res)
    Measure-PCXCorrelationConfidence -CorrelationResult $res
} $correlationResult
$stage3Sw.Stop()

$totalSw.Stop()

# Calculate percentages
$totalMs = $totalSw.ElapsedMilliseconds
$stage1Ms = $stage1Sw.ElapsedMilliseconds
$stage2Ms = $stage2Sw.ElapsedMilliseconds
$stage3Ms = $stage3Sw.ElapsedMilliseconds

$stage1Pct = if ($totalMs -gt 0) { [Math]::Round(($stage1Ms / $totalMs) * 100, 2) } else { 0 }
$stage2Pct = if ($totalMs -gt 0) { [Math]::Round(($stage2Ms / $totalMs) * 100, 2) } else { 0 }
$stage3Pct = if ($totalMs -gt 0) { [Math]::Round(($stage3Ms / $totalMs) * 100, 2) } else { 0 }

# Output Timing Summary
Write-Host ""
Write-Host "=== SYNCHRONIZATION PIPELINE TIMING SUMMARY ===" -ForegroundColor Green
Write-Host ("{0,-38} : {1,8:N2} ms ({2,6:N2}%)" -f "Stage 1 (Get-PCXAudioActivity x2)", $stage1Ms, $stage1Pct)
Write-Host ("{0,-38} : {1,8:N2} ms ({2,6:N2}%)" -f "Stage 2A (Search-PCXAudioCorrelation)", $stage2Ms, $stage2Pct)
Write-Host ("{0,-38} : {1,8:N2} ms ({2,6:N2}%)" -f "Stage 3A (Measure-PCXCorrelationConfidence)", $stage3Ms, $stage3Pct)
Write-Host ("{0,-38} : {1,8:N2} ms (100.00%)" -f "Total Execution Time", $totalMs)
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

return [PSCustomObject]@{
    Stage1_AudioActivity_ms    = $stage1Ms
    Stage1_AudioActivity_pct   = $stage1Pct
    Stage2A_AudioCorr_ms       = $stage2Ms
    Stage2A_AudioCorr_pct      = $stage2Pct
    Stage3A_Confidence_ms      = $stage3Ms
    Stage3A_Confidence_pct     = $stage3Pct
    TotalTime_ms               = $totalMs
    Result                     = [PSCustomObject]@{
        Offset                = $correlationResult.BestOffset
        Correlation           = $correlationResult.Correlation
        Confidence            = $confidence
        SecondPeakCorrelation = $correlationResult.SecondPeakCorrelation
        OverlapFraction       = $correlationResult.OverlapFraction
    }
}
