# Gemini Provider Setup

## Prerequisites

- Python 3.12 available
- Mark-XL virtual environment created
- `google-genai` installed
- Gemini API key stored outside Git

## Install SDK

Inside the Mark-XL virtual environment:

```powershell
cd P:\Projects\mark-xl
.\.venv\Scripts\Activate.ps1
python -m pip install -U google-genai
```

## Set the API key

Set your key as a Windows user environment variable:

```powershell
[Environment]::SetEnvironmentVariable("GEMINI_API_KEY", "YOUR_KEY", "User")
```

Set it for the current terminal too:

```powershell
$env:GEMINI_API_KEY = "YOUR_KEY"
```

## Test the key

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\jarvis-mark-xl\test-gemini.ps1
```

Expected output:

```text
READY
```

## Enable Gemini provider

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\jarvis-mark-xl\set-gemini-provider.ps1 -Model "gemini-3.5-flash"
```

Then launch Mark-XL:

```powershell
python main.py
```

## Return to Ollama

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\jarvis-mark-xl\set-ollama-provider.ps1 -Model "llama3.2:3b"
```
