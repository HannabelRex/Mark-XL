$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $RepoRoot

powershell -ExecutionPolicy Bypass -File .\scripts\jarvis-mark-xl\verify-hotfix-02b.ps1

git status --short
git add docs\jarvis-mark-xl\hotfix-02b-safety-bootstrap-path-repair.md scripts\jarvis-mark-xl\test-safety-guard.ps1 scripts\jarvis-mark-xl\start-safe.ps1 scripts\jarvis-mark-xl\verify-phase-02.ps1 scripts\jarvis-mark-xl\verify-hotfix-02b.ps1 scripts\jarvis-mark-xl\commit-hotfix-02b.ps1 scripts\jarvis-mark-xl\commit-phase-02.ps1

git commit -m "fix: ensure Jarvis safety bootstrap loads from safe scripts"
git push origin jarvis/base-integration

Write-Host "Hotfix 02B committed and pushed." -ForegroundColor Green
