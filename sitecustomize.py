"""Optional Jarvis safety bootstrap for Mark-XL.

Python imports this file automatically when it is present on sys.path. The guard is
inactive unless JARVIS_SAFETY_ENABLE is set to 1/true/yes/on.
"""
from __future__ import annotations

import os

if os.environ.get("JARVIS_SAFETY_ENABLE", "").strip().lower() in {"1", "true", "yes", "on"}:
    try:
        from core.jarvis_safety_runtime import bootstrap

        bootstrap()
    except Exception as exc:  # pragma: no cover - startup diagnostic only
        print(f"[JARVIS SAFETY] Guard failed to load: {exc}")
