# Safe Launch Guide

## Normal developer launch

```powershell
cd P:\Projects\mark-xl
.\.venv\Scripts\Activate.ps1
python main.py
```

## Safe launch with confirmation prompts

```powershell
cd P:\Projects\mark-xl
.\.venv\Scripts\Activate.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\jarvis-mark-xl\start-safe.ps1 -Mode confirm
```

## Safe launch with observe-only logging

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\jarvis-mark-xl\start-safe.ps1 -Mode observe
```

## Safe launch with blocking

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\jarvis-mark-xl\start-safe.ps1 -Mode block
```

## Audit log

By default, safety decisions are written to:

```text
logs/jarvis_safety_audit.log
```

Do not commit logs. The Phase 02 `.gitignore` patch ignores `logs/` and `*.log`.
