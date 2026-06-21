param(
    [string]$RepoRoot = "P:\Projects\mark-xl",
    [string]$Model = "llama3.2:3b",
    [string]$Url = "http://localhost:11434"
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

$config["llm_provider"] = "ollama"
$config["llm_model"] = $Model
$config["llm_url"] = $Url

$config | ConvertTo-Json -Depth 10 | Set-Content -Path $configPath -Encoding UTF8

Write-Host "Configured Mark-XL provider: ollama" -ForegroundColor Green
Write-Host "Ollama model: $Model" -ForegroundColor Green
Write-Host "Ollama URL: $Url" -ForegroundColor Green
