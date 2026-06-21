# Hotfix 02A - Safety Verification Script Repair

## Purpose

Phase 02 added the first opt-in safety and permission baseline for Mark-XL. The runtime safety guard was valid, but the verification harness had two issues on Windows PowerShell:

1. The inline `python -c` safety test could be quote-mangled by Windows PowerShell, producing a false Python syntax error.
2. `verify-phase-02.ps1` launched the safety test as a native process without checking the child process exit code, so it could print a success message after the safety test failed.

## Fix

This hotfix changes `test-safety-guard.ps1` to write the Python safety test to a temporary file under `logs/` and execute that file. This avoids command-line quote parsing problems.

It also updates `verify-phase-02.ps1` to check `$LASTEXITCODE` after both the Python compile check and the safety guard test script.

## Expected result

Running this command should now fail honestly if the safety test fails, and pass only when the safety guard actually blocks deletion:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\jarvis-mark-xl\verify-phase-02.ps1
```

Expected output:

```text
Safety guard test passed.
Phase 02 Safety and permission baseline verification passed.
```
