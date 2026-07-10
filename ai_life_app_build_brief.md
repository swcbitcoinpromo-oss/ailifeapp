# AI Life Coach App — Build Brief

*Reference document for Cowork. Paste into Project → Context. Cowork executes against this.*

---

## 1. What we're building

An **iOS app (SwiftUI)** with **three AI coaches** that give a **daily morning briefing** and **coordinate with each other** to push one set of goals.

The user types notes into text boxes. The app:
- Parses those notes into an **interactive calendar**
- Detects **recurring patterns** (e.g. gym every Monday) and auto-populates events
- Delivers a **morning briefing** each day via a **call-style video interface** with voice
- Runs **three coordinated coaches**: Calendar, Gym, Nutrition — each owns a domain and talks to the others

---

## 2. THE ONE GROUND RULE (read first)

**All coach personalities, voices, and faces are ORIGINAL characters — not real, named public figures.**

- Coaches are **archetypes**: a sharp planner, an intense drill-style trainer, a data-driven nutrition coach.
- Their **philosophy and tone** is written into each coach's system prompt.
- **No cloning** of real people's voices, no deepfaked real faces, no ingesting anyone's copyrighted books.

**Why:** real living public figures are protected by right-of-publicity and copyright law. Using their likeness/voice/books in a shipping App Store product is a rejection-and-lawsuit risk. Original characters keep ~95% of the magic with **zero legal exposure.** This decision shapes the whole build, so it's locked at the top.

---

## 3. Architecture (three tiers)

**Tier 1 — iOS app (SwiftUI)**
Runs on the phone. Handles input, calendar UI, briefing playback, notifications, local storage. Talks to the server.

**Tier 2 — Server (the 24/7 box)**
The brain. Hosts the API the app calls, runs the coach orchestration, calls Claude for the thinking, runs the **overnight job** that pre-generates tomorrow's briefing + video.
**Recommended stack: Python + FastAPI** (plays to your existing Python/VPS strengths).

**Tier 3 — External services**
- **Claude API** → parsing notes, pattern detection, coaching logic, writing the briefing script
- **Runway** → generating the briefing video (you've confirmed you're paying for this)

---

## 4. The three coaches + how they talk to each other

Working names (rename/restyle freely — keep them original):

- **Planner** → calendar & life organisation. Structured, work-ethic.
- **Drill** → gym & physical performance. Intense, no-excuses.
- **Fuel** → health & nutrition. Methodical, data-driven.

**Coordination pattern: shared state + orchestrator** (a clean multi-agent design).

1. Each coach is a Claude call with **its own system prompt** (personality + domain) plus read access to a **shared user-state object** (goals, recent logs, calendar, other coaches' latest recommendations).
2. When the user logs food, **Fuel** processes it and writes a recommendation to shared state.
3. The **orchestrator** sees "goal = bulk + new meal plan" and triggers **Drill** to bias toward muscle-building work.
4. **Drill** writes its plan; the orchestrator triggers **Planner** to add/adjust gym sessions **around the user's real schedule**.

**Result:** change one thing, the whole system re-optimises toward the goal.

> **Nutrition safety note:** Fuel should promote **sustainable, balanced** eating — never extreme cuts or crash protocols. Ship a plain **"not medical advice"** disclaimer in the health section.

---

## 5. Core features

- **Text-in → calendar-out**: notes parsed into structured events automatically
- **Pattern detection**: recurring habits become recurring events (with a confirm step)
- **Interactive calendar**: view, edit, confirm, delete
- **Domain input screens**: general/schedule, gym log, food log
- **Morning briefing**: assembled from tomorrow's day + each coach's input
- **Call-style video briefing**: original coach avatar delivers it (see §7)
- **Morning notification** + auto-play on app open + **resume-if-interrupted** (video sits on server, plays next open)

---

## 6. Data model (core objects)

- **User profile & goals** — e.g. goal=bulk, target, schedule constraints
- **Calendar event** — title, datetime, recurrence, source, domain tag
- **Detected pattern** — type, cadence, confidence
- **Food log** — date, entries, notes/macros
- **Workout log** — date, exercises, volume
- **Coach recommendation** — coach, date, recommendation, status
- **Briefing record** — date, script, video URL, played flag

**On-device storage:** SwiftData (or Core Data). Server holds the synced copy the overnight job reads.

---

## 7. The "FaceTime-style" briefing

- Build a **call-style interface** with your **own original design** — do **not** clone Apple's exact FaceTime UI or use FaceTime branding (Apple rejects apps that impersonate system apps).
- The face on screen is an **original coach character**: an illustrated/animated character, or an AI-generated original presenter. **Not a real person.**
- **Voice:** start with **system TTS** to ship fast. Upgrade later to **your own recorded voice per coach** (free, yours) or an original synthetic voice. Claude writes the script in each coach's tone regardless.

---

## 8. Overnight video pipeline (fully hands-off)

Runs on the server so you never touch it after setup:

1. **~11 PM cron job** fires.
2. Pull **tomorrow's calendar + latest logs + goals**.
3. **Orchestrator** runs all three coaches → assembles the **briefing script**.
4. Script → **Runway** → video generated → **stored on server**.
5. **Morning:** app opens → fetches the ready video → plays in the call UI.
6. Also fires the **morning local notification**.

Interrupted (phone off, etc.)? The video's already on the server — it just plays next open.

---

## 9. Build phases (always shippable at each step)

**Phase 1 — Core loop, no AI**
Scaffold SwiftUI project → calendar view + manual event CRUD → input screens → local storage → running end-to-end with dummy data.

**Phase 2 — Claude parsing + calendar intelligence**
Server + Claude API → notes → structured events → pattern detection → auto-populate.

**Phase 3 — The three coaches**
Shared state store → three coach prompts → orchestrator + cross-talk → each domain feeds its coach.

**Phase 4 — Briefing (text + voice)**
Assemble script → system TTS → call-style UI → morning notification + auto-play + resume logic.

**Phase 5 — Video call**
Original coach avatar → Runway pipeline → overnight job → call playback.

**Phase 6 — Polish / optional**
Refinements. (Optional local-LLM research layer — see below.)

---

## 10. Tech stack summary

- **Frontend:** SwiftUI, SwiftData, UNUserNotificationCenter, AVKit (playback)
- **Backend:** Python + FastAPI on the 24/7 box, cron for the overnight job
- **AI:** Claude API (parsing, coaching, scripts)
- **Video:** Runway
- **Voice:** system TTS → own recordings later

---

## 11. Open decisions to confirm

- **Coach names + personalities** (original — you define them)
- **Coach visual style** for video (illustrated character vs original AI presenter)
- **Voice approach** (system TTS first; own recordings later?)
- **Local LLM research layer?** — *Recommendation: skip at launch.* Claude API handles all coaching, and a local LLM adds cost + maintenance. Add later only if volume justifies it. Ground coaches in **publicly-known principles + optional live web research**, not ingested books.

---

## 12. First task for Cowork

> **Scaffold the SwiftUI iOS project** for "AI Life Coach App." Create the base project structure with a tab layout for three sections — Calendar, Coaches, and Input — plus an empty SwiftData model file stubbing the core objects in §6. No AI or networking yet; just a clean, running skeleton with placeholder views.
