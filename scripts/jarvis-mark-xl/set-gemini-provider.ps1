param(
    [string]$RepoRoot = "P:\Projects\mark-xl",
    [string]$Model = "gemini-3.5-flash"
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path $RepoRoot).Path
$configDir = Join-Path $RepoRoot "config"
$configPath = Join-Path $configDir "api_keys.json"

if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

$config = @{}
if (Test-Path $configPath) {
    try {
        $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json -AsHashtable
    } catch {
        throw "Could not parse config/api_keys.json. Fix JSON first: $($_.Exception.Message)"
    }
}

$config["llm_provider"] = "gemini"
$config["gemini_model"] = $Model

$config | ConvertTo-Json -Depth 10 | Set-Content -Path $configPath -Encoding UTF8

Write-Host "Configured Mark-XL provider: gemini" -ForegroundColor Green
Write-Host "Gemini model: $Model" -ForegroundColor Green
Write-Host "API key was NOT written to config/api_keys.json. Keep using GEMINI_API_KEY or GOOGLE_API_KEY." -ForegroundColor Yellow
