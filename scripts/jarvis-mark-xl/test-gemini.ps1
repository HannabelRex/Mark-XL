param(
    [string]$RepoRoot = "P:\Projects\mark-xl",
    [string]$Model = "gemini-3.5-flash"
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path $RepoRoot).Path
Set-Location $RepoRoot

if (-not $env:GEMINI_API_KEY -and -not $env:GOOGLE_API_KEY) {
    throw "GEMINI_API_KEY or GOOGLE_API_KEY is not set for this PowerShell session."
}

$venvPython = Join-Path $RepoRoot ".venv\Scripts\python.exe"
$python = if (Test-Path $venvPython) { $venvPython } else { "python" }

$testFile = Join-Path $RepoRoot ".jarvis_gemini_test.py"
@"
from google import genai

client = genai.Client()
response = client.models.generate_content(
    model="$Model",
    contents="Reply with exactly one word: READY"
)
print((response.text or "").strip())
"@ | Set-Content -Path $testFile -Encoding UTF8

try {
    & $python $testFile
} finally {
    Remove-Item $testFile -Force -ErrorAction SilentlyContinue
}
