# Model Provider Routing

## Default strategy

Jarvis should remain local-first by default.

Recommended routing:

| Workload | Provider | Model |
|---|---|---|
| Private files, screen content, desktop automation | Ollama | `llama3.2:3b` or `llama3.1:8b` |
| Coding help | Ollama | `qwen2.5-coder:7b` |
| Higher quality general reasoning | Gemini | `gemini-3.5-flash` |
| Sensitive actions | Ollama | local model only |

## Current Phase 01 limitation

Gemini is text-only in this first bridge phase. It does not execute Mark-XL desktop/browser/file tools yet.

This is deliberate. Tool execution through a cloud model needs extra permission gates, explicit confirmation UX, and schema conversion.

## Configuration fields

`config/api_keys.json` can contain:

```json
{
  "llm_provider": "gemini",
  "gemini_model": "gemini-3.5-flash"
}
```

For Ollama:

```json
{
  "llm_provider": "ollama",
  "llm_model": "llama3.2:3b",
  "llm_url": "http://localhost:11434"
}
```

## Environment override

You can override the provider without changing config:

```powershell
$env:JARVIS_PROVIDER = "gemini"
$env:GEMINI_MODEL = "gemini-3.5-flash"
python main.py
```

To clear override:

```powershell
Remove-Item Env:\JARVIS_PROVIDER -ErrorAction SilentlyContinue
Remove-Item Env:\GEMINI_MODEL -ErrorAction SilentlyContinue
```
