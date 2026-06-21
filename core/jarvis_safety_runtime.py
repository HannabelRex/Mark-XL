"""Runtime safety guard for Mark-XL.

This module is intentionally opt-in. It is activated by sitecustomize.py only when
JARVIS_SAFETY_ENABLE=1. It adds a confirmation/block/observe layer around common
high-impact desktop actions without changing Mark-XL's normal startup path.
"""
from __future__ import annotations

import builtins
import datetime as _dt
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any, Callable

_BOOTSTRAPPED = False
_ORIGINALS: dict[str, Any] = {}
_PATCHED_PYAUTOGUI = False

BASE_DIR = Path(__file__).resolve().parent.parent
DEFAULT_LOG_PATH = BASE_DIR / "logs" / "jarvis_safety_audit.log"

RISKY_COMMAND_PATTERNS: tuple[re.Pattern[str], ...] = tuple(
    re.compile(pattern, re.IGNORECASE)
    for pattern in (
        r"\brm\s+-rf\b",
        r"\bdel\b",
        r"\brmdir\b",
        r"\bremove-item\b",
        r"\bformat\b",
        r"\bdiskpart\b",
        r"\bshutdown\b",
        r"\brestart-computer\b",
        r"\bstop-computer\b",
        r"\breg\s+delete\b",
        r"\bset-executionpolicy\b",
        r"\bgit\s+push\b.*\b--force\b",
        r"\btaskkill\b.*\b/f\b",
    )
)

PYAUTOGUI_RISKY_CALLS = {
    "click",
    "doubleClick",
    "rightClick",
    "middleClick",
    "dragTo",
    "dragRel",
    "press",
    "hotkey",
    "write",
    "typewrite",
    "keyDown",
    "keyUp",
    "scroll",
    "hscroll",
}


def _mode() -> str:
    raw = os.environ.get("JARVIS_SAFETY_MODE", "confirm").strip().lower()
    if raw not in {"confirm", "block", "observe"}:
        return "confirm"
    return raw


def _audit_path() -> Path:
    configured = os.environ.get("JARVIS_SAFETY_LOG", "").strip()
    if configured:
        return Path(configured).expanduser().resolve()
    return DEFAULT_LOG_PATH


def _log(event: dict[str, Any]) -> None:
    event = dict(event)
    event.setdefault("timestamp", _dt.datetime.now().isoformat(timespec="seconds"))
    event.setdefault("mode", _mode())
    event.setdefault("pid", os.getpid())
    try:
        path = _audit_path()
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("a", encoding="utf-8") as handle:
            handle.write(json.dumps(event, ensure_ascii=False, default=str) + "\n")
    except Exception:
        # Safety logging must never crash the assistant.
        pass


def _is_noninteractive() -> bool:
    return os.environ.get("JARVIS_SAFETY_NONINTERACTIVE", "").strip().lower() in {
        "1",
        "true",
        "yes",
        "on",
    }


def _confirm(action: str, detail: str, risk: str = "high") -> None:
    mode = _mode()
    payload = {"action": action, "detail": detail, "risk": risk}

    if mode == "observe":
        _log({**payload, "decision": "observed"})
        return

    if mode == "block":
        _log({**payload, "decision": "blocked"})
        raise PermissionError(f"Jarvis safety guard blocked {action}: {detail}")

    if _is_noninteractive() or not sys.stdin:
        _log({**payload, "decision": "denied_noninteractive"})
        raise PermissionError(f"Jarvis safety guard requires confirmation for {action}: {detail}")

    print("\n[JARVIS SAFETY] High-impact action requested")
    print(f"  Action: {action}")
    print(f"  Detail: {detail}")
    print("  Type YES to approve this one action, anything else to deny.")
    try:
        answer = input("Approve? ").strip()
    except Exception:
        answer = ""

    if answer == "YES":
        _log({**payload, "decision": "approved"})
        return

    _log({**payload, "decision": "denied"})
    raise PermissionError(f"Jarvis safety guard denied {action}: {detail}")


def _cmd_to_text(cmd: Any) -> str:
    if isinstance(cmd, (list, tuple)):
        return " ".join(str(part) for part in cmd)
    return str(cmd)


def _command_looks_risky(command_text: str) -> bool:
    return any(pattern.search(command_text) for pattern in RISKY_COMMAND_PATTERNS)


def _guard_subprocess(action_name: str, original: Callable[..., Any]) -> Callable[..., Any]:
    def wrapper(*args: Any, **kwargs: Any) -> Any:
        command_text = _cmd_to_text(args[0]) if args else ""
        if _command_looks_risky(command_text):
            _confirm(f"subprocess.{action_name}", command_text, "high")
        return original(*args, **kwargs)

    return wrapper


def _guard_file_delete(action_name: str, original: Callable[..., Any]) -> Callable[..., Any]:
    def wrapper(path: Any, *args: Any, **kwargs: Any) -> Any:
        _confirm(action_name, str(path), "high")
        return original(path, *args, **kwargs)

    return wrapper


def _patch_core_apis() -> None:
    if "subprocess.run" not in _ORIGINALS:
        _ORIGINALS["subprocess.run"] = subprocess.run
        subprocess.run = _guard_subprocess("run", subprocess.run)  # type: ignore[assignment]

    if "subprocess.Popen" not in _ORIGINALS:
        _ORIGINALS["subprocess.Popen"] = subprocess.Popen
        subprocess.Popen = _guard_subprocess("Popen", subprocess.Popen)  # type: ignore[assignment]

    if "subprocess.call" not in _ORIGINALS:
        _ORIGINALS["subprocess.call"] = subprocess.call
        subprocess.call = _guard_subprocess("call", subprocess.call)  # type: ignore[assignment]

    if "subprocess.check_call" not in _ORIGINALS:
        _ORIGINALS["subprocess.check_call"] = subprocess.check_call
        subprocess.check_call = _guard_subprocess("check_call", subprocess.check_call)  # type: ignore[assignment]

    if "subprocess.check_output" not in _ORIGINALS:
        _ORIGINALS["subprocess.check_output"] = subprocess.check_output
        subprocess.check_output = _guard_subprocess("check_output", subprocess.check_output)  # type: ignore[assignment]

    if "os.remove" not in _ORIGINALS:
        _ORIGINALS["os.remove"] = os.remove
        os.remove = _guard_file_delete("os.remove", os.remove)  # type: ignore[assignment]

    if "os.unlink" not in _ORIGINALS:
        _ORIGINALS["os.unlink"] = os.unlink
        os.unlink = _guard_file_delete("os.unlink", os.unlink)  # type: ignore[assignment]

    if "os.rmdir" not in _ORIGINALS:
        _ORIGINALS["os.rmdir"] = os.rmdir
        os.rmdir = _guard_file_delete("os.rmdir", os.rmdir)  # type: ignore[assignment]

    if "shutil.rmtree" not in _ORIGINALS:
        _ORIGINALS["shutil.rmtree"] = shutil.rmtree
        shutil.rmtree = _guard_file_delete("shutil.rmtree", shutil.rmtree)  # type: ignore[assignment]

    if "Path.unlink" not in _ORIGINALS:
        _ORIGINALS["Path.unlink"] = Path.unlink
        Path.unlink = _guard_file_delete("Path.unlink", Path.unlink)  # type: ignore[assignment]

    if "Path.rmdir" not in _ORIGINALS:
        _ORIGINALS["Path.rmdir"] = Path.rmdir
        Path.rmdir = _guard_file_delete("Path.rmdir", Path.rmdir)  # type: ignore[assignment]


def _patch_pyautogui(module: Any) -> None:
    global _PATCHED_PYAUTOGUI
    if _PATCHED_PYAUTOGUI or module is None:
        return

    for name in PYAUTOGUI_RISKY_CALLS:
        if not hasattr(module, name):
            continue
        key = f"pyautogui.{name}"
        original = getattr(module, name)
        _ORIGINALS[key] = original

        def make_wrapper(call_name: str, fn: Callable[..., Any]) -> Callable[..., Any]:
            def wrapper(*args: Any, **kwargs: Any) -> Any:
                detail = f"args={args!r}, kwargs={kwargs!r}"
                _confirm(f"pyautogui.{call_name}", detail, "medium")
                return fn(*args, **kwargs)

            return wrapper

        setattr(module, name, make_wrapper(name, original))

    _PATCHED_PYAUTOGUI = True
    _log({"action": "pyautogui.patch", "detail": "desktop interaction calls wrapped", "decision": "installed"})


def _install_import_hook() -> None:
    if "builtins.__import__" in _ORIGINALS:
        return

    original_import = builtins.__import__
    _ORIGINALS["builtins.__import__"] = original_import

    def guarded_import(name: str, globals: Any = None, locals: Any = None, fromlist: tuple = (), level: int = 0) -> Any:
        module = original_import(name, globals, locals, fromlist, level)
        try:
            if name == "pyautogui" or name.startswith("pyautogui"):
                _patch_pyautogui(sys.modules.get("pyautogui"))
        except Exception as exc:
            _log({"action": "pyautogui.patch", "detail": str(exc), "decision": "failed"})
        return module

    builtins.__import__ = guarded_import


def bootstrap() -> None:
    """Install the opt-in runtime guard once."""
    global _BOOTSTRAPPED
    if _BOOTSTRAPPED:
        return
    _BOOTSTRAPPED = True
    _patch_core_apis()
    _install_import_hook()
    _log({"action": "safety.bootstrap", "detail": "runtime guard enabled", "decision": "installed"})
    print(f"[JARVIS SAFETY] Runtime guard enabled in {_mode()} mode.")
