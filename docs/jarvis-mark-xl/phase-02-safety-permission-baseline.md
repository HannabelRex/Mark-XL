# Jarvis Mark-XL Phase 02 - Safety and Permission Baseline

## Status

Phase 02 adds an opt-in safety layer for Mark-XL while preserving the normal upstream startup path.

## Why this phase exists

Mark-XL is powerful because it can control the computer. That also makes it risky. This phase adds a guardrail before we continue with voice, UI, browser, file, and desktop automation work.

## What was added

- `sitecustomize.py` opt-in safety bootstrap
- `core/jarvis_safety_runtime.py` runtime guard
- `config/jarvis_safety.example.json` safety reference config
- Safe launch script
- Guard test script
- Verification and commit scripts
- Documentation for risk levels and operating modes
- `.gitignore` hygiene for local Python artifacts and secrets

## Safety modes

| Mode | Behavior | Recommended use |
|---|---|---|
| observe | Logs risky actions but allows them | Debugging only |
| confirm | Prompts before risky actions | Normal safe Jarvis use |
| block | Blocks risky actions automatically | Smoke tests and high caution |

## Guarded areas in this phase

- File deletion APIs: `os.remove`, `os.unlink`, `os.rmdir`, `shutil.rmtree`, `Path.unlink`, `Path.rmdir`
- Risky subprocess patterns such as forced deletes, shutdown, registry deletion, disk formatting, force pushes
- PyAutoGUI desktop actions such as click, press, hotkey, type/write, drag, and scroll

## What this phase does not do yet

- It does not redesign the UI approval flow.
- It does not add per-tool policy screens.
- It does not prevent every possible file write.
- It does not give Gemini direct tool execution permission.

Those come later, because building a complete permission system in one commit is how projects turn into smoking craters.
