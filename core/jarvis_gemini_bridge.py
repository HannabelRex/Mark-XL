"""
Jarvis Gemini provider bridge for Mark-XL.

This module is intentionally loaded as a small compatibility bridge from
core/llm_client.py. It keeps the original Ollama/OpenAI-compatible behavior
intact and only overrides the LLM entry points when the selected provider is
Gemini.

Provider selection order:
1. JARVIS_PROVIDER environment variable
2. llm_provider in config/api_keys.json
3. original Mark-XL provider behavior

Secret handling:
- GEMINI_API_KEY is read from the environment by google-genai.
- No API key is stored in this file.
"""

from __future__ import annotations

import json
import os
import re
import sys
from pathlib import Path
from typing import Callable, Generator

_SENT_END = re.compile(r"(?<=[.!?])\s+|(?<=\n)\s*\n")


def _get_base_dir() -> Path:
    if getattr(sys, "frozen", False):
        return Path(sys.executable).parent
    return Path(__file__).resolve().parent.parent


BASE_DIR = _get_base_dir()
CONFIG_PATH = BASE_DIR / "config" / "api_keys.json"


def _load_config() -> dict:
    try:
        return json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    except Exception:
        return {}


def _selected_provider(cfg: dict) -> str:
    raw = os.environ.get("JARVIS_PROVIDER") or cfg.get("llm_provider", "")
    return str(raw or "").strip().lower()


def _is_gemini_provider(cfg: dict | None = None) -> bool:
    cfg = cfg or _load_config()
    return _selected_provider(cfg) in {"gemini", "google", "googleai", "google-genai"}


def _gemini_model(cfg: dict | None = None, model: str | None = None) -> str:
    cfg = cfg or _load_config()
    explicit = model or os.environ.get("GEMINI_MODEL") or cfg.get("gemini_model")
    if explicit:
        return str(explicit).strip()

    llm_model = str(cfg.get("llm_model", "")).strip()
    if llm_model.startswith("gemini-"):
        return llm_model

    # The user's API key smoke test validated this model successfully.
    return "gemini-3.5-flash"


def _require_genai_client():
    if not os.environ.get("GEMINI_API_KEY") and not os.environ.get("GOOGLE_API_KEY"):
        raise RuntimeError(
            "Gemini provider selected but GEMINI_API_KEY or GOOGLE_API_KEY is not set. "
            "Set it in your Windows user environment before launching Mark-XL."
        )

    try:
        from google import genai  # type: ignore
    except Exception as exc:
        raise RuntimeError(
            "Gemini provider selected but google-genai is not installed. "
            "Run: python -m pip install -U google-genai"
        ) from exc

    return genai.Client()


def _messages_to_prompt(messages: list) -> str:
    parts: list[str] = []
    for msg in messages or []:
        if not isinstance(msg, dict):
            parts.append(str(msg))
            continue
        role = str(msg.get("role", "user")).strip().upper() or "USER"
        content = msg.get("content", "")
        if isinstance(content, list):
            content = "\n".join(str(item) for item in content)
        parts.append(f"{role}: {content}")
    return "\n\n".join(part for part in parts if part.strip())


def _split_sentences(text: str) -> list[str]:
    text = (text or "").strip()
    if not text:
        return []

    chunks: list[str] = []
    buf = text
    while True:
        match = _SENT_END.search(buf)
        if not match:
            break
        sentence = buf[: match.start() + 1].strip()
        if sentence:
            chunks.append(sentence)
        buf = buf[match.end() :]
    if buf.strip():
        chunks.append(buf.strip())
    return chunks or [text]


def _generate_text(messages: list, model: str | None = None, timeout: int = 120) -> str:
    # google-genai currently handles HTTP timeouts internally through its client.
    # Keep timeout in the signature so callers remain compatible with Mark-XL.
    del timeout
    client = _require_genai_client()
    selected_model = _gemini_model(model=model)
    prompt = _messages_to_prompt(messages)
    response = client.models.generate_content(model=selected_model, contents=prompt)
    return (getattr(response, "text", "") or "").strip()


def install_gemini_bridge(namespace: dict) -> None:
    """Install Gemini-aware replacements into core.llm_client globals."""

    original_get_llm_provider = namespace.get("get_llm_provider")
    original_get_llm_settings = namespace.get("get_llm_settings")
    original_ensure_ollama_running = namespace.get("ensure_ollama_running")
    original_warmup_model = namespace.get("warmup_model")
    original_check_model_available = namespace.get("check_model_available")
    original_call_llm = namespace.get("call_llm")
    original_call_llm_text = namespace.get("call_llm_text")
    original_call_llm_stream = namespace.get("call_llm_stream")

    def get_llm_provider() -> str:
        cfg = _load_config()
        if _is_gemini_provider(cfg):
            return "gemini"
        if callable(original_get_llm_provider):
            return original_get_llm_provider()
        return "ollama"

    def get_llm_settings() -> tuple[str, str]:
        cfg = _load_config()
        if _is_gemini_provider(cfg):
            return "gemini://generativelanguage", _gemini_model(cfg)
        if callable(original_get_llm_settings):
            return original_get_llm_settings()
        return "http://localhost:11434", "llama3.2"

    def ensure_ollama_running(timeout: int = 15) -> bool:
        if get_llm_provider() == "gemini":
            try:
                _require_genai_client()
                print("[LLM] Gemini provider selected; API key and SDK are available.")
                return True
            except Exception as exc:
                print(f"[LLM] Gemini provider check failed: {exc}")
                return False
        if callable(original_ensure_ollama_running):
            return original_ensure_ollama_running(timeout=timeout)
        return True

    def warmup_model(system_prompt: str | None = None) -> bool:
        if get_llm_provider() == "gemini":
            try:
                messages = []
                if system_prompt:
                    messages.append({"role": "system", "content": system_prompt})
                messages.append({"role": "user", "content": "Reply with exactly one word: READY"})
                _generate_text(messages, timeout=60)
                print(f"[LLM] Gemini model '{_gemini_model()}' reachable.")
                return True
            except Exception as exc:
                print(f"[LLM] Gemini warmup failed: {exc}")
                return False
        if callable(original_warmup_model):
            return original_warmup_model(system_prompt=system_prompt)
        return True

    def check_model_available(log: Callable | None = None) -> bool:
        if get_llm_provider() == "gemini":
            message = f"Gemini provider selected: {_gemini_model()}"
            print(f"[LLM] {message}")
            if log:
                log(f"SYS: {message}")
            return True
        if callable(original_check_model_available):
            return original_check_model_available(log=log)
        return True

    def call_llm(messages: list, tools: list | None = None, timeout: int = 120) -> dict:
        if get_llm_provider() != "gemini":
            if callable(original_call_llm):
                return original_call_llm(messages, tools=tools, timeout=timeout)
            raise RuntimeError("Original call_llm is not available.")

        # Conservative first integration: Gemini handles natural-language replies.
        # Mark-XL tool execution remains safest on Ollama/OpenAI-compatible models
        # until we add explicit Gemini function-call schema conversion.
        if tools:
            print("[LLM] Gemini provider received tools; returning text-only response for Phase 01.")

        content = _generate_text(messages, timeout=timeout)
        return {"content": content, "tool_calls": []}

    def call_llm_text(
        prompt: str,
        system: str | None = None,
        model: str | None = None,
        timeout: int = 120,
    ) -> str:
        if get_llm_provider() != "gemini":
            if callable(original_call_llm_text):
                return original_call_llm_text(prompt, system=system, model=model, timeout=timeout)
            raise RuntimeError("Original call_llm_text is not available.")

        messages: list[dict] = []
        if system:
            messages.append({"role": "system", "content": system})
        messages.append({"role": "user", "content": prompt})
        return _generate_text(messages, model=model, timeout=timeout)

    def call_llm_stream(
        messages: list,
        tools: list | None = None,
        timeout: int = 120,
    ) -> Generator[dict, None, None]:
        if get_llm_provider() != "gemini":
            if callable(original_call_llm_stream):
                yield from original_call_llm_stream(messages, tools=tools, timeout=timeout)
                return
            raise RuntimeError("Original call_llm_stream is not available.")

        content = _generate_text(messages, timeout=timeout)
        for sentence in _split_sentences(content):
            yield {"type": "sentence", "text": sentence}
        yield {"type": "done", "content": content, "tool_calls": []}

    namespace["get_llm_provider"] = get_llm_provider
    namespace["get_llm_settings"] = get_llm_settings
    namespace["ensure_ollama_running"] = ensure_ollama_running
    namespace["warmup_model"] = warmup_model
    namespace["check_model_available"] = check_model_available
    namespace["call_llm"] = call_llm
    namespace["call_llm_text"] = call_llm_text
    namespace["call_llm_stream"] = call_llm_stream
