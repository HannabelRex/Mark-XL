$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $RepoRoot

Remove-Item Env:JARVIS_SAFETY_ENABLE -ErrorAction SilentlyContinue
Remove-Item Env:JARVIS_SAFETY_MODE -ErrorAction SilentlyContinue
Remove-Item Env:JARVIS_SAFETY_LOG -ErrorAction SilentlyContinue
Remove-Item Env:JARVIS_SAFETY_NONINTERACTIVE -ErrorAction SilentlyContinue

Write-Host "Starting Mark-XL without Jarvis safety guard environment variables." -ForegroundColor Yellow
python main.py
