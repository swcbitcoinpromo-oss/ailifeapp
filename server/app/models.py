"""Pydantic models mirroring the shared user-state object from the coach prompts doc.

The JSON keys here are load-bearing: all three coach prompts read/write this shape.
Rename coaches freely, keep the keys identical (coach doc, 'Notes for the build').
"""

from __future__ import annotations

from typing import Any, Optional

from pydantic import BaseModel, Field


# ---------- Shared state ----------

class Constraints(BaseModel):
    schedule: str = ""
    dietary: str = ""
    injuries: str = ""


class UserProfile(BaseModel):
    goal: str = ""          # e.g. "bulk"
    level: str = ""         # e.g. "intermediate"
    constraints: Constraints = Field(default_factory=Constraints)


class CalendarEvent(BaseModel):
    title: str
    start: str              # ISO 8601
    end: Optional[str] = None
    recurrence: Optional[str] = None
    domain: str = "general"     # general | gym | nutrition
    source: str = "manual"      # manual | parsed | coach


class FoodLog(BaseModel):
    date: str
    entries: str = ""
    notes: str = ""


class WorkoutLog(BaseModel):
    date: str
    exercises: str = ""
    volume_notes: str = ""


class CoachRecommendations(BaseModel):
    atlas: dict[str, Any] = Field(default_factory=dict)
    forge: dict[str, Any] = Field(default_factory=dict)
    sage: dict[str, Any] = Field(default_factory=dict)


class SharedState(BaseModel):
    """The object every coach receives (coach doc, 'How they coordinate')."""

    user_profile: UserProfile = Field(default_factory=UserProfile)
    calendar: list[CalendarEvent] = Field(default_factory=list)
    recent_food_logs: list[FoodLog] = Field(default_factory=list)
    recent_workout_logs: list[WorkoutLog] = Field(default_factory=list)
    coach_recommendations: CoachRecommendations = Field(default_factory=CoachRecommendations)


# ---------- Coach outputs (strict JSON each coach must return) ----------

class DetectedPattern(BaseModel):
    description: str
    cadence: str
    confidence: float
    needs_confirmation: bool = True


class AtlasOutput(BaseModel):
    events: list[CalendarEvent] = Field(default_factory=list)
    patterns_detected: list[DetectedPattern] = Field(default_factory=list)
    schedule_notes: str = ""
    briefing_line: str = ""


class SessionRequest(BaseModel):
    type: str
    duration_min: int
    priority: str


class ForgeOutput(BaseModel):
    training_focus: str = ""
    session_requests: list[SessionRequest] = Field(default_factory=list)
    progression_notes: str = ""
    briefing_line: str = ""


class Adjustment(BaseModel):
    change: str
    reason: str


class SageOutput(BaseModel):
    nutrition_plan: str = ""
    adjustments: list[Adjustment] = Field(default_factory=list)
    fuel_status_for_training: str = ""
    health_flags: list[str] = Field(default_factory=list)
    briefing_line: str = ""


# ---------- Briefing ----------

class Briefing(BaseModel):
    date: str
    script: str
    video_url: Optional[str] = None
    played: bool = False
