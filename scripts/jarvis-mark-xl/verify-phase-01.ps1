param(
    [string]$RepoRoot = "P:\Projects\mark-xl"
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path $RepoRoot).Path
Set-Location $RepoRoot

$requiredFiles = @(
    "core\jarvis_gemini_bridge.py",
    "docs\jarvis-mark-xl\phase-01-gemini-provider-foundation.md",
    "docs\jarvis-mark-xl\gemini-provider-setup.md",
    "docs\jarvis-mark-xl\model-provider-routing.md",
    "docs\jarvis-mark-xl\secret-handling.md",
    "scripts\jarvis-mark-xl\test-gemini.ps1",
    "scripts\jarvis-mark-xl\set-gemini-provider.ps1",
    "scripts\jarvis-mark-xl\set-ollama-provider.ps1",
    "scripts\jarvis-mark-xl\commit-phase-01.ps1"
)

foreach ($file in $requiredFiles) {
    if (-not (Test-Path (Join-Path $RepoRoot $file))) {
        throw "Missing required file: $file"
    }
}

$llmText = Get-Content -Path (Join-Path $RepoRoot "core\llm_client.py") -Raw
if ($llmText -notmatch "install_gemini_bridge") {
    throw "core/llm_client.py does not load the Gemini bridge."
}

$reqText = Get-Content -Path (Join-Path $RepoRoot "requirements.txt") -Raw
if ($reqText -notmatch "google-genai") {
    throw "requirements.txt does not include google-genai."
}

$venvPython = Join-Path $RepoRoot ".venv\Scripts\python.exe"
$python = if (Test-Path $venvPython) { $venvPython } else { "python" }

& $python -m py_compile `
    (Join-Path $RepoRoot "core\jarvis_gemini_bridge.py") `
    (Join-Path $RepoRoot "core\llm_client.py")

Write-Host "Phase 01 Gemini provider foundation verification passed." -ForegroundColor Green
