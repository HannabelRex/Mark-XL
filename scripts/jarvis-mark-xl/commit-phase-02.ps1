$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $RepoRoot

powershell -ExecutionPolicy Bypass -File .\scripts\jarvis-mark-xl\verify-phase-02.ps1

# Include Hotfix 02A/02B docs and verification helpers if they exist, because
# this phase was stabilized before the first successful Phase 02 commit.
$FilesToStage = @(
  ".gitignore",
  "sitecustomize.py",
  "core\jarvis_safety_runtime.py",
  "config\jarvis_safety.example.json",
  "docs\jarvis-mark-xl\phase-02-safety-permission-baseline.md",
  "docs\jarvis-mark-xl\safety-permission-model.md",
  "docs\jarvis-mark-xl\safe-launch-guide.md",
  "docs\jarvis-mark-xl\tool-risk-map.md",
  "docs\jarvis-mark-xl\hotfix-02a-safety-verify-script-repair.md",
  "docs\jarvis-mark-xl\hotfix-02b-safety-bootstrap-path-repair.md",
  "scripts\jarvis-mark-xl\start-safe.ps1",
  "scripts\jarvis-mark-xl\start-normal.ps1",
  "scripts\jarvis-mark-xl\test-safety-guard.ps1",
  "scripts\jarvis-mark-xl\verify-phase-02.ps1",
  "scripts\jarvis-mark-xl\verify-hotfix-02a.ps1",
  "scripts\jarvis-mark-xl\verify-hotfix-02b.ps1",
  "scripts\jarvis-mark-xl\commit-phase-02.ps1",
  "scripts\jarvis-mark-xl\commit-hotfix-02a.ps1"
)

$ExistingFiles = $FilesToStage | Where-Object { Test-Path $_ }

git status --short
git add -- $ExistingFiles
git commit -m "feat: add Jarvis safety permission baseline"
git push origin jarvis/base-integration

Write-Host "Phase 02 committed and pushed." -ForegroundColor Green
