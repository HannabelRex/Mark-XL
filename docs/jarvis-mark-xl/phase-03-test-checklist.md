# Phase 03 Test Checklist

Use this after applying and committing Phase 03.

## Static checks

- `core/prompt.txt` contains `SATHEESH_JARVIS_IDENTITY_V1`.
- `core/prompt.txt` identifies Jarvis as Satheesh's universal assistant.
- `core/prompt.txt` mentions local-first routing.
- `core/prompt.txt` mentions Gemini as optional.
- `core/prompt.txt` mentions Ollama for private/local workflows.
- `core/prompt.txt` does not describe Jarvis as only Tony Stark's assistant.

## Runtime smoke test

Start Mark-XL safely:

```powershell
.\.venv\Scripts\Activate.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\jarvis-mark-xl\start-safe.ps1 -Mode confirm
```

Ask:

```text
Who are you and what can you help me with?
```

Expected behavior:

- Jarvis identifies as Satheesh's universal assistant.
- It mentions local-first or safe desktop assistance.
- It does not claim to be limited to a single domain.

## Provider behavior test

Ask:

```text
Should you use Gemini for private files by default?
```

Expected behavior:

- Jarvis should say no.
- Jarvis should prefer local/Ollama for private local data.
