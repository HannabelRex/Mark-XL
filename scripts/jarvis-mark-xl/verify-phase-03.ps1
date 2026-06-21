$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$PromptPath = Join-Path $RepoRoot "core\prompt.txt"
$IdentityConfigPath = Join-Path $RepoRoot "config\jarvis_identity.example.json"

$RequiredFiles = @(
    $PromptPath,
    $IdentityConfigPath,
    (Join-Path $RepoRoot "docs\jarvis-mark-xl\phase-03-identity-universal-behavior.md"),
    (Join-Path $RepoRoot "docs\jarvis-mark-xl\jarvis-identity-profile.md"),
    (Join-Path $RepoRoot "docs\jarvis-mark-xl\universal-assistant-behavior.md"),
    (Join-Path $RepoRoot "docs\jarvis-mark-xl\phase-03-test-checklist.md"),
    (Join-Path $RepoRoot "scripts\jarvis-mark-xl\commit-phase-03.ps1")
)

foreach ($File in $RequiredFiles) {
    if (-not (Test-Path $File)) {
        throw "Missing required Phase 03 file: $File"
    }
}

$Prompt = Get-Content $PromptPath -Raw

$RequiredMarkers = @(
    "SATHEESH_JARVIS_IDENTITY_V1",
    "Satheesh's universal personal AI assistant",
    "LOCAL-FIRST OPERATING MODEL",
    "Use Gemini only when it is configured",
    "Prefer local tools and local Ollama models",
    "SAFETY AND PERMISSIONS",
    "MEMORY PRIVACY"
)

foreach ($Marker in $RequiredMarkers) {
    if ($Prompt -notlike "*$Marker*") {
        throw "Prompt is missing required marker: $Marker"
    }
}

if ($Prompt -like "*Tony Stark's AI assistant*") {
    throw "Prompt still contains upstream Tony Stark identity text."
}

$IdentityJson = Get-Content $IdentityConfigPath -Raw | ConvertFrom-Json
if ($IdentityJson.assistant_name -ne "Jarvis") {
    throw "Identity config assistant_name must be Jarvis."
}
if ($IdentityJson.operator_name -ne "Satheesh") {
    throw "Identity config operator_name must be Satheesh."
}
if ($IdentityJson.privacy_mode -ne "local_first") {
    throw "Identity config privacy_mode must be local_first."
}

Write-Host "Phase 03 identity and universal behavior verification passed."
