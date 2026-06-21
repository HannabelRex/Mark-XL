# Hotfix 02B - Safety Bootstrap Path Repair

## Problem

Hotfix 02A repaired the quoting bug in the PowerShell verification script, but the safety runtime still did not load in the test process. The test script was created under `logs/`, so Python used `logs/` as `sys.path[0]` and did not automatically discover the repo-root `sitecustomize.py` file.

That meant `os.remove` was not wrapped and the verification correctly failed with:

```text
Expected os.remove to be blocked
```

## Fix

Hotfix 02B ensures repo-root `sitecustomize.py` is discoverable by adding the repository root to `PYTHONPATH` in:

- `scripts/jarvis-mark-xl/test-safety-guard.ps1`
- `scripts/jarvis-mark-xl/start-safe.ps1`

The verification now asserts that both scripts contain the `PYTHONPATH` bootstrap marker and then re-runs the blocking delete test.

## Safety result

The delete test should now print:

```text
Safety guard test passed.
Phase 02 Safety and permission baseline verification passed.
Hotfix 02B verification passed.
```

## Notes

This hotfix does not make the safety runtime global. It remains opt-in through `JARVIS_SAFETY_ENABLE=1` and the safe launcher.
