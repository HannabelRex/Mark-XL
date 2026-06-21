$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $RepoRoot

git status --short
powershell -ExecutionPolicy Bypass -File .\scripts\jarvis-mark-xl\verify-hotfix-02a.ps1

git add docs\jarvis-mark-xl\hotfix-02a-safety-verify-script-repair.md scripts\jarvis-mark-xl\test-safety-guard.ps1 scripts\jarvis-mark-xl\verify-phase-02.ps1 scripts\jarvis-mark-xl\verify-hotfix-02a.ps1 scripts\jarvis-mark-xl\commit-hotfix-02a.ps1

git commit -m "fix: repair Jarvis safety verification script"
git push
