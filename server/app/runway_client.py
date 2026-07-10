"""Runway video generation for the call-style morning briefing (brief §7–8).

GROUND RULE (brief §2): the on-screen presenter is an ORIGINAL character —
an illustrated or AI-generated avatar you own. No real people's faces or
voices, no FaceTime branding in the UI.

Wire-up once you have the Runway subscription:
  1. Put the API key in server/.env as RUNWAYML_API_SECRET
     (create the key at dev.runwayml.com after subscribing)
  2. Drop original avatar images in server/assets/avatars/  (atlas.png, forge.png, sage.png)
  3. Check the current video model name in Runway's docs and set RUNWAY_MODEL in .env
  4. VERIFY the SDK call shape below against current docs — Runway's API evolves;
     the structure (create task → poll → download URL) is stable, parameter
     names may not be.

Voice note: the app plays the briefing with on-device TTS first (brief §7);
baked-in audio/lip-sync is a later upgrade.
"""

import os
import urllib.request
from datetime import date
from pathlib import Path

SERVER_ROOT = Path(__file__).resolve().parent.parent
VIDEO_DIR = SERVER_ROOT / "videos"
AVATAR_DIR = SERVER_ROOT / "assets" / "avatars"


def generate_briefing_video(script: str, coach: str = "atlas") -> Path:
    """Animate the original coach avatar delivering the briefing. Returns local mp4 path."""
    if not os.getenv("RUNWAYML_API_SECRET"):
        raise RuntimeError(
            "RUNWAYML_API_SECRET not set — add it to server/.env once the Runway subscription is active."
        )
    avatar = AVATAR_DIR / f"{coach}.png"
    if not avatar.exists():
        raise RuntimeError(
            f"Missing original avatar image: {avatar}. Add your own original character art first."
        )

    from runwayml import RunwayML  # pip install runwayml

    client = RunwayML()  # reads RUNWAYML_API_SECRET from env

    with open(avatar, "rb") as f:
        import base64

        avatar_data_uri = "data:image/png;base64," + base64.b64encode(f.read()).decode()

    # Image-to-video: bring the still avatar to life for the briefing.
    # VERIFY parameter names against current docs (dev.runwayml.com).
    task = client.image_to_video.create(
        model=os.getenv("RUNWAY_MODEL", "gen4_turbo"),
        prompt_image=avatar_data_uri,
        prompt_text=(
            "Animated original coach character, friendly and energetic, "
            "speaking directly to camera as if on a video call, subtle natural "
            "head and mouth movement, clean background."
        ),
        ratio="720:1280",
        duration=10,
    ).wait_for_task_output()

    video_url = task.output[0]
    VIDEO_DIR.mkdir(parents=True, exist_ok=True)
    out_path = VIDEO_DIR / f"briefing-{date.today().isoformat()}.mp4"
    urllib.request.urlretrieve(video_url, out_path)
    return out_path
