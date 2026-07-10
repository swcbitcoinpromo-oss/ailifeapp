"""Overnight briefing job (brief §8) — run by cron ~11 PM, fully hands-off.

Crontab entry (adjust paths):
    0 23 * * * cd /path/to/ailifeapp/server && ./.venv/bin/python jobs/overnight.py >> overnight.log 2>&1

Steps: load state → run all three coaches → assemble script → (if Runway key
present) generate the avatar video → store both. The app fetches the ready
briefing in the morning; if the phone was off, it just plays on next open.
"""

import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app import store  # noqa: E402
from app.orchestrator import run_daily_flow  # noqa: E402
from app.runway_client import generate_briefing_video  # noqa: E402


def main() -> None:
    state = store.load_state()
    state, briefing = run_daily_flow(state)

    if os.getenv("RUNWAYML_API_SECRET"):
        try:
            video_path = generate_briefing_video(briefing.script)
            briefing.video_url = f"/videos/{video_path.name}"
        except Exception as exc:  # video is best-effort; script briefing still ships
            print(f"Runway generation failed, shipping script-only briefing: {exc}")
    else:
        print("RUNWAYML_API_SECRET not set — script-only briefing (video arrives in Phase 5).")

    store.save_state(state)
    store.save_briefing(briefing)
    print(f"Briefing ready for {briefing.date}: {briefing.script[:80]}...")


if __name__ == "__main__":
    main()
