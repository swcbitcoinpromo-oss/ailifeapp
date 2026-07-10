"""AI Life Coach — server API (Tier 2, brief §3).

Run locally:
    cd server
    python -m venv .venv && source .venv/bin/activate
    pip install -r requirements.txt
    cp .env.example .env   # fill in keys
    uvicorn app.main:app --reload

The iOS app talks only to this API. Claude + Runway calls happen here.
"""

from datetime import date

from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

from . import store
from .models import FoodLog, SharedState, WorkoutLog
from .orchestrator import run_daily_flow
from .runway_client import VIDEO_DIR, generate_briefing_video

app = FastAPI(title="AI Life Coach API")

VIDEO_DIR.mkdir(parents=True, exist_ok=True)
app.mount("/videos", StaticFiles(directory=str(VIDEO_DIR)), name="videos")


@app.get("/health")
def health() -> dict:
    return {"ok": True}


# ---------- Shared state ----------

@app.get("/v1/state")
def get_state() -> SharedState:
    return store.load_state()


@app.put("/v1/state")
def put_state(state: SharedState) -> dict:
    store.save_state(state)
    return {"ok": True}


# ---------- Domain inputs ----------

class LogBody(BaseModel):
    text: str
    notes: str = ""


@app.post("/v1/logs/food")
def log_food(body: LogBody) -> dict:
    state = store.load_state()
    state.recent_food_logs.append(
        FoodLog(date=date.today().isoformat(), entries=body.text, notes=body.notes)
    )
    store.save_state(state)
    return {"ok": True, "count": len(state.recent_food_logs)}


@app.post("/v1/logs/workout")
def log_workout(body: LogBody) -> dict:
    state = store.load_state()
    state.recent_workout_logs.append(
        WorkoutLog(date=date.today().isoformat(), exercises=body.text, volume_notes=body.notes)
    )
    store.save_state(state)
    return {"ok": True, "count": len(state.recent_workout_logs)}


class NotesBody(BaseModel):
    text: str


@app.post("/v1/notes/schedule")
def schedule_notes(body: NotesBody) -> dict:
    """Phase 2: parse raw notes into events via Atlas. Requires ANTHROPIC_API_KEY."""
    from . import coach_prompts
    from .claude_client import run_coach

    state = store.load_state()
    atlas_out = run_coach(coach_prompts.ATLAS_PROMPT, state.model_dump(), body.text)
    state.coach_recommendations.atlas = atlas_out
    store.save_state(state)
    return atlas_out


# ---------- Briefing ----------

@app.post("/v1/briefing/generate")
def generate_briefing(include_video: bool = False) -> dict:
    """Manual trigger of the overnight flow (the cron job calls the same code)."""
    state = store.load_state()
    state, briefing = run_daily_flow(state)
    if include_video:
        video_path = generate_briefing_video(briefing.script)
        briefing.video_url = f"/videos/{video_path.name}"
    store.save_state(state)
    store.save_briefing(briefing)
    return briefing.model_dump()


@app.get("/v1/briefing/today")
def briefing_today() -> dict:
    briefing = store.load_briefing(date.today().isoformat())
    if briefing is None:
        raise HTTPException(status_code=404, detail="No briefing generated for today yet.")
    return briefing.model_dump()


@app.post("/v1/briefing/played")
def briefing_played() -> dict:
    briefing = store.load_briefing(date.today().isoformat())
    if briefing is None:
        raise HTTPException(status_code=404, detail="No briefing for today.")
    briefing.played = True
    store.save_briefing(briefing)
    return {"ok": True}
