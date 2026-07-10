"""Thin Claude API wrapper — every coach turn goes through run_coach().

Wire-up: copy server/.env.example to server/.env and set ANTHROPIC_API_KEY.
"""

import json
import os

from dotenv import load_dotenv

load_dotenv()

MODEL = os.getenv("CLAUDE_MODEL", "claude-sonnet-5")

_client = None


def _get_client():
    global _client
    if _client is None:
        key = os.getenv("ANTHROPIC_API_KEY")
        if not key:
            raise RuntimeError(
                "ANTHROPIC_API_KEY not set — copy server/.env.example to server/.env and fill it in."
            )
        from anthropic import Anthropic

        _client = Anthropic(api_key=key)
    return _client


def run_coach(system_prompt: str, shared_state: dict, user_input: str) -> dict:
    """One coach turn: shared state + new domain input -> parsed JSON dict."""
    message = _get_client().messages.create(
        model=MODEL,
        max_tokens=2000,
        system=system_prompt,
        messages=[
            {
                "role": "user",
                "content": (
                    "SHARED STATE:\n"
                    + json.dumps(shared_state, indent=2)
                    + "\n\nNEW INPUT FOR YOUR DOMAIN:\n"
                    + user_input
                    + "\n\nRespond ONLY with the JSON object your instructions specify."
                ),
            }
        ],
    )
    text = message.content[0].text
    # Tolerate accidental markdown fences; extract the outermost JSON object.
    start, end = text.find("{"), text.rfind("}")
    if start == -1 or end == -1:
        raise ValueError(f"Coach did not return JSON: {text[:200]}")
    return json.loads(text[start : end + 1])
