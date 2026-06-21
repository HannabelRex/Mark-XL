# Jarvis Mark-XL Safety Permission Model

## Principle

Jarvis should answer freely but act carefully.

Text generation is low-risk. Desktop, browser, file, shell, and messaging actions are higher risk and should move through confirmation or policy checks.

## Provider trust model

| Provider | Good for | Tool execution default |
|---|---|---|
| Ollama local | Private files, desktop actions, sensitive workflows | Allowed only through safety guard |
| Gemini cloud | Planning, reasoning, summarizing, coding help | Text-only until explicit permission phases |

## Action risk levels

| Level | Examples | Baseline handling |
|---|---|---|
| Low | Read current time, summarize visible text | Allow |
| Medium | Click, type, open app, browser navigation | Confirm in safe mode |
| High | Delete files, run shell commands, edit settings | Confirm or block |
| Critical | Format disk, delete registry, force push, credential access | Block until explicit allowlist exists |

## Current enforcement

Phase 02 provides runtime wrapping for common destructive or desktop-control APIs. It is intentionally launched through `start-safe.ps1` so normal development remains possible.

## Future enforcement

Later phases should add:

1. A visible approval dialog in the Mark-XL UI.
2. A per-tool allowlist.
3. A per-folder file access policy.
4. Separate cloud-provider tool execution rules.
5. Audit export for all accepted/denied actions.
