param(
    [ValidateSet("observe", "confirm", "block")]
    [string]$Mode = "confirm"
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $RepoRoot

# Ensure repo-root sitecustomize.py is discoverable even when this script is
# launched from another working directory or by a shortcut.
$PathSeparator = [System.IO.Path]::PathSeparator
if ([string]::IsNullOrWhiteSpace($env:PYTHONPATH)) {
    $env:PYTHONPATH = $RepoRoot
} elseif ($env:PYTHONPATH -notlike "*$RepoRoot*") {
    $env:PYTHONPATH = "$RepoRoot$PathSeparator$env:PYTHONPATH"
}

$env:JARVIS_SAFETY_ENABLE = "1"
$env:JARVIS_SAFETY_MODE = $Mode
$env:JARVIS_SAFETY_LOG = Join-Path $RepoRoot "logs\jarvis_safety_audit.log"

Write-Host "Starting Mark-XL with Jarvis safety guard enabled." -ForegroundColor Cyan
Write-Host "Mode: $Mode" -ForegroundColor Cyan
Write-Host "Audit log: $env:JARVIS_SAFETY_LOG" -ForegroundColor Cyan
Write-Host "PYTHONPATH includes repo root: $RepoRoot" -ForegroundColor DarkCyan

python main.py
exit $LASTEXITCODE
