"""Orchestrator — fires the coaches in sequence against shared state (brief §4).

Flow (coach doc): food log → Sage → Forge (reads fuel status) → Atlas (places
sessions into real slots). Each coach's JSON output is written back into
shared state; their briefing_lines are stitched into the morning script.
"""

from datetime import date

from . import coach_prompts
from .claude_client import run_coach
from .models import Briefing, SharedState


def run_daily_flow(
    state: SharedState,
    schedule_notes: str = "",
    workout_note: str = "",
    food_note: str = "",
) -> tuple[SharedState, Briefing]:
    """Run Sage → Forge → Atlas, mutate state, return (state, briefing)."""
    state_dict = state.model_dump()

    # 1. SAGE — nutrition first, so Forge knows the fuel picture.
    sage_out = run_coach(
        coach_prompts.SAGE_PROMPT,
        state_dict,
        food_note or "No new food log today. Assess recent logs.",
    )
    state_dict["coach_recommendations"]["sage"] = sage_out

    # Care-response: if Sage raised health flags, keep the day gentle —
    # pass through, don't escalate coaching intensity downstream.
    health_flags = sage_out.get("health_flags") or []

    # 2. FORGE — training, coordinated with Sage's fuel status.
    forge_out = run_coach(
        coach_prompts.FORGE_PROMPT,
        state_dict,
        workout_note or "No new workout log today. Assess recent logs.",
    )
    state_dict["coach_recommendations"]["forge"] = forge_out

    # 3. ATLAS — parse notes + place Forge/Sage session requests into real slots.
    atlas_out = run_coach(
        coach_prompts.ATLAS_PROMPT,
        state_dict,
        schedule_notes or "No new schedule notes. Place pending session requests.",
    )
    state_dict["coach_recommendations"]["atlas"] = atlas_out

    new_state = SharedState.model_validate(state_dict)

    # Assemble the morning script: Atlas sets the shape, Forge brings fire,
    # Sage brings the fuel plan (coach doc, 'Notes for the build').
    lines = [
        atlas_out.get("briefing_line", ""),
        forge_out.get("briefing_line", ""),
        sage_out.get("briefing_line", ""),
    ]
    script = "Good morning. " + " ".join(line for line in lines if line)
    if health_flags:
        script = (
            "Good morning. Gentle one today. "
            + (sage_out.get("briefing_line") or "Take care of yourself first — the rest can wait.")
        )

    briefing = Briefing(date=date.today().isoformat(), script=script)
    return new_state, briefing
