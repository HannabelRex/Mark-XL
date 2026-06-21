$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $RepoRoot

$RequiredFiles = @(
    "sitecustomize.py",
    "core\jarvis_safety_runtime.py",
    "config\jarvis_safety.example.json",
    "docs\jarvis-mark-xl\phase-02-safety-permission-baseline.md",
    "docs\jarvis-mark-xl\safety-permission-model.md",
    "docs\jarvis-mark-xl\safe-launch-guide.md",
    "docs\jarvis-mark-xl\tool-risk-map.md",
    "scripts\jarvis-mark-xl\start-safe.ps1",
    "scripts\jarvis-mark-xl\start-normal.ps1",
    "scripts\jarvis-mark-xl\test-safety-guard.ps1",
    "scripts\jarvis-mark-xl\verify-phase-02.ps1",
    "scripts\jarvis-mark-xl\commit-phase-02.ps1"
)

foreach ($File in $RequiredFiles) {
    if (-not (Test-Path $File)) {
        throw "Missing required Phase 02 file: $File"
    }
}

$Runtime = Get-Content .\core\jarvis_safety_runtime.py -Raw
foreach ($Needle in @("JARVIS_SAFETY_ENABLE", "JARVIS_SAFETY_MODE", "os.remove", "subprocess.run", "pyautogui")) {
    if ($Runtime -notmatch [regex]::Escape($Needle)) {
        throw "Safety runtime missing expected marker: $Needle"
    }
}

$SiteCustomize = Get-Content .\sitecustomize.py -Raw
if ($SiteCustomize -notmatch "jarvis_safety_runtime") {
    throw "sitecustomize.py does not load the Jarvis safety runtime."
}

$StartSafe = Get-Content .\scripts\jarvis-mark-xl\start-safe.ps1 -Raw
if ($StartSafe -notmatch "PYTHONPATH") {
    throw "start-safe.ps1 does not ensure repo-root sitecustomize.py is discoverable through PYTHONPATH."
}

$TestScript = Get-Content .\scripts\jarvis-mark-xl\test-safety-guard.ps1 -Raw
if ($TestScript -notmatch "PYTHONPATH") {
    throw "test-safety-guard.ps1 does not set PYTHONPATH for sitecustomize discovery."
}

& powershell -ExecutionPolicy Bypass -File .\scripts\jarvis-mark-xl\test-safety-guard.ps1
if ($LASTEXITCODE -ne 0) {
    throw "Safety guard script failed."
}

Write-Host "Phase 02 Safety and permission baseline verification passed." -ForegroundColor Green
