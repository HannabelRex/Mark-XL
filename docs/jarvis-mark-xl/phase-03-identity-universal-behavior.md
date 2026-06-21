# Jarvis Mark-XL Phase 03: Identity and Universal Assistant Behavior

## Purpose

Phase 03 replaces the generic upstream assistant prompt with a personal Jarvis identity for Satheesh.

This phase keeps Mark-XL universal. Jarvis is not an SAP-only assistant, HR-only assistant, coding-only assistant, or stock-only assistant. Those are specialist modes inside one larger local-first personal AI system.

## What changed

- Replaced `core/prompt.txt` with a Jarvis identity prompt.
- Added `config/jarvis_identity.example.json` as a documented identity reference.
- Added behavior rules for local-first privacy, Gemini routing, Ollama fallback, tool routing, safety confirmations, and memory privacy.
- Added verification and commit scripts.

## Runtime impact

Mark-XL already loads `core/prompt.txt` as the system prompt during startup. Because of that, this phase can change behavior without a larger runtime rewrite.

## Safety posture

This phase reinforces Phase 02. Risky desktop, file, browser, message, command, or automation actions should be treated carefully and confirmed before execution unless the safety runtime has already handled the confirmation.

## Provider posture

- Use Ollama for private, file-based, screen-based, desktop-control, and sensitive workflows.
- Use Gemini only as an optional cloud reasoning provider when it is useful and safe.

## Verification

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\jarvis-mark-xl\verify-phase-03.ps1
```

Expected:

```text
Phase 03 identity and universal behavior verification passed.
```
