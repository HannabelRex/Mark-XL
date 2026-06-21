# Jarvis Mark-XL Phase 01 - Gemini Provider Foundation

## Purpose

Phase 01 adds an optional Gemini provider layer to Mark-XL while keeping the original local Ollama behavior intact.

The goal is not to replace local-first operation. The goal is to allow Jarvis to use Gemini when you explicitly select it, while keeping Ollama available as the privacy-friendly fallback.

## What changed

Added:

- `core/jarvis_gemini_bridge.py`
- `docs/jarvis-mark-xl/gemini-provider-setup.md`
- `docs/jarvis-mark-xl/model-provider-routing.md`
- `docs/jarvis-mark-xl/secret-handling.md`
- `scripts/jarvis-mark-xl/test-gemini.ps1`
- `scripts/jarvis-mark-xl/set-gemini-provider.ps1`
- `scripts/jarvis-mark-xl/set-ollama-provider.ps1`
- `scripts/jarvis-mark-xl/verify-phase-01.ps1`
- `scripts/jarvis-mark-xl/commit-phase-01.ps1`

Patched:

- `core/llm_client.py`
- `core/installer.py`
- `requirements.txt`

## Provider behavior

Supported provider modes after this phase:

- `ollama` - original local Mark-XL behavior
- `openai` - original OpenAI-compatible server behavior
- `gemini` - new Jarvis Gemini provider bridge

## Safety decision

This first Gemini phase is intentionally conservative.

Gemini can produce normal assistant responses through Mark-XL, but action/tool execution remains local-first for now. If Gemini receives a tool-enabled request, the bridge returns text and no tool calls.

That keeps desktop/file/browser control away from the cloud provider until we add explicit tool permission mapping and confirmation gates.

## Secret handling

Do not commit your Gemini API key.

Use a Windows user environment variable:

```powershell
[Environment]::SetEnvironmentVariable("GEMINI_API_KEY", "YOUR_KEY", "User")
```

For the current PowerShell session:

```powershell
$env:GEMINI_API_KEY = "YOUR_KEY"
```

## Verification

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\jarvis-mark-xl\verify-phase-01.ps1
```

Then run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\jarvis-mark-xl\test-gemini.ps1
```

Expected Gemini test output:

```text
READY
```
