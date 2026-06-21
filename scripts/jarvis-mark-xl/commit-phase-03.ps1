$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $RepoRoot

powershell -ExecutionPolicy Bypass -File (Join-Path $RepoRoot "scripts\jarvis-mark-xl\verify-phase-03.ps1")
if ($LASTEXITCODE -ne 0) {
    throw "Phase 03 verification failed."
}

git status --short

git add .gitignore

git add core/prompt.txt

git add config/jarvis_identity.example.json

git add docs/jarvis-mark-xl/phase-03-identity-universal-behavior.md

git add docs/jarvis-mark-xl/jarvis-identity-profile.md

git add docs/jarvis-mark-xl/universal-assistant-behavior.md

git add docs/jarvis-mark-xl/phase-03-test-checklist.md

git add scripts/jarvis-mark-xl/verify-phase-03.ps1

git add scripts/jarvis-mark-xl/commit-phase-03.ps1

$Pending = git diff --cached --name-only
if (-not $Pending) {
    Write-Host "No staged Phase 03 changes found. Nothing to commit."
    exit 0
}

git commit -m "feat: add Jarvis identity and universal behavior"
git push origin jarvis/base-integration

Write-Host "Phase 03 committed and pushed."
