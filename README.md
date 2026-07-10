# AI Life Coach App

Three original AI coaches — **Atlas** (calendar), **Forge** (gym), **Sage** (nutrition) —
that coordinate through shared state and deliver a daily morning briefing via a
call-style video interface. Full plan: `ai_life_app_build_brief.md` · coach
prompts: `coach_system_prompts.md`.

**The one ground rule:** every coach personality, face and voice is an ORIGINAL
character. Never real named people (brief §2).

## Folder layout

```
AILifeCoach.xcodeproj/   Xcode project (open this)
AILifeCoach/             iOS app source (SwiftUI + Core Data)
server/                  Tier-2 backend (Python + FastAPI) — Phases 2–5
ai_life_app_build_brief.md
coach_system_prompts.md
```

## Status by phase

- **Phase 1 — iOS skeleton: DONE** (pending first build). Three tabs
  (Calendar / Coaches / Input), manual event CRUD, gym & food logs persist
  locally, all six core data objects stubbed.
- **Phase 2 — Claude parsing: scaffolded.** `server/` runs locally; the
  `/v1/notes/schedule` endpoint parses notes via Atlas once
  `ANTHROPIC_API_KEY` is set. iOS→server wiring still to come.
- **Phase 3 — coach orchestration: scaffolded.** `server/app/orchestrator.py`
  runs Sage → Forge → Atlas against shared state.
- **Phase 4 — briefing (text+voice): script assembly scaffolded;** call-style
  UI + TTS + notifications still to build in the app.
- **Phase 5 — video: pipeline scaffolded.** `server/app/runway_client.py` +
  `server/jobs/overnight.py` (cron). Needs: Runway subscription → API key in
  `server/.env`, original avatar images in `server/assets/avatars/`, and a
  param check against current Runway docs before first run.

## Building the iOS app (this Mac)

Requires **Xcode 14.2** (max for macOS 12.7 — that's why SwiftData was swapped
for Core Data and the deployment target is iOS 16).

1. Double-click `AILifeCoach.xcodeproj`
2. Destination: any iPhone simulator (iOS 16.2 ships with Xcode 14.2)
3. Press **Cmd+R**

## Running the server

```
cd server
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env        # add keys as you get them
uvicorn app.main:app --reload
```

Overnight briefing cron (brief §8): see `server/jobs/overnight.py` header.

## Decision record

- **2026-07-10** Core Data instead of SwiftData; Xcode-14-format project;
  iOS 16 target — hard ceiling of macOS 12.7.6 host. Brief §6 allows either.
- Coach names Atlas/Forge/Sage are working placeholders — rename freely,
  keep the JSON keys identical (coach doc, final note).
- Nutrition guardrails + "not medical advice" line ship in-product (brief §4).
