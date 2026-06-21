$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $RepoRoot

$RequiredFiles = @(
    "scripts\jarvis-mark-xl\test-safety-guard.ps1",
    "scripts\jarvis-mark-xl\verify-phase-02.ps1",
    "docs\jarvis-mark-xl\hotfix-02a-safety-verify-script-repair.md"
)

foreach ($File in $RequiredFiles) {
    if (-not (Test-Path (Join-Path $RepoRoot $File))) {
        throw "Missing hotfix file: $File"
    }
}

$TestScriptText = Get-Content .\scripts\jarvis-mark-xl\test-safety-guard.ps1 -Raw
if ($TestScriptText -notlike "*safety-test-delete.py*") {
    throw "test-safety-guard.ps1 was not updated to use a temporary Python test file."
}

$VerifyText = Get-Content .\scripts\jarvis-mark-xl\verify-phase-02.ps1 -Raw
if ($VerifyText -notlike "*Safety guard script failed*") {
    throw "verify-phase-02.ps1 was not updated to check the test script exit code."
}

powershell -ExecutionPolicy Bypass -File .\scripts\jarvis-mark-xl\verify-phase-02.ps1
if ($LASTEXITCODE -ne 0) {
    throw "Phase 02 verification failed after hotfix."
}

Write-Host "Hotfix 02A verification passed." -ForegroundColor Green
