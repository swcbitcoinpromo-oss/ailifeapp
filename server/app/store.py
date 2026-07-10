"""Dead-simple JSON file persistence for the scaffold (swap for a DB later)."""

import json
from pathlib import Path

from .models import Briefing, SharedState

DATA_DIR = Path(__file__).resolve().parent.parent / "data"
STATE_PATH = DATA_DIR / "state.json"
BRIEFING_DIR = DATA_DIR / "briefings"


def load_state() -> SharedState:
    if STATE_PATH.exists():
        return SharedState.model_validate_json(STATE_PATH.read_text())
    return SharedState()


def save_state(state: SharedState) -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    STATE_PATH.write_text(state.model_dump_json(indent=2))


def save_briefing(briefing: Briefing) -> None:
    BRIEFING_DIR.mkdir(parents=True, exist_ok=True)
    (BRIEFING_DIR / f"{briefing.date}.json").write_text(briefing.model_dump_json(indent=2))


def load_briefing(day: str) -> Briefing | None:
    path = BRIEFING_DIR / f"{day}.json"
    if path.exists():
        return Briefing.model_validate_json(path.read_text())
    return None
