$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $RepoRoot

foreach ($File in @(
    "docs\jarvis-mark-xl\hotfix-02b-safety-bootstrap-path-repair.md",
    "scripts\jarvis-mark-xl\test-safety-guard.ps1",
    "scripts\jarvis-mark-xl\start-safe.ps1",
    "scripts\jarvis-mark-xl\verify-phase-02.ps1"
)) {
    if (-not (Test-Path $File)) {
        throw "Missing Hotfix 02B file: $File"
    }
}

$TestScript = Get-Content .\scripts\jarvis-mark-xl\test-safety-guard.ps1 -Raw
if ($TestScript -notmatch "PYTHONPATH" -or $TestScript -notmatch "import sitecustomize") {
    throw "Hotfix 02B test script markers missing."
}

$StartSafe = Get-Content .\scripts\jarvis-mark-xl\start-safe.ps1 -Raw
if ($StartSafe -notmatch "PYTHONPATH" -or $StartSafe -notmatch "sitecustomize.py") {
    throw "Hotfix 02B start-safe markers missing."
}

& powershell -ExecutionPolicy Bypass -File .\scripts\jarvis-mark-xl\verify-phase-02.ps1
if ($LASTEXITCODE -ne 0) {
    throw "Phase 02 verification failed after Hotfix 02B."
}

Write-Host "Hotfix 02B verification passed." -ForegroundColor Green
