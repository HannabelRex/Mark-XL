param(
    [string]$RepoRoot = "P:\Projects\mark-xl"
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path $RepoRoot).Path
Set-Location $RepoRoot

powershell -ExecutionPolicy Bypass -File .\scripts\jarvis-mark-xl\verify-phase-01.ps1 -RepoRoot $RepoRoot

git status --short

git add core\jarvis_gemini_bridge.py core\llm_client.py core\installer.py requirements.txt docs\jarvis-mark-xl scripts\jarvis-mark-xl

git commit -m "feat: add Gemini provider foundation"

git push origin HEAD
