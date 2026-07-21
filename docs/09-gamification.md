# 9. Gamification System

Implementation: `frontend/src/data/gamification.ts`, `frontend/src/data/missions.ts`,
`frontend/src/store/gameStore.ts`.

## 9.1 XP & leveling

- Every meaningful action across all 9 modules awards XP (see per-module tables in
  `08-screens.md`).
- XP required to reach level *N+1* from *N* is `80·N² + 120·N` — quadratic pacing so early levels
  feel fast and later levels represent real cumulative mastery.
- `levelForTotalXp()` derives current level, XP-into-level, and XP-for-next purely from
  `totalXp`, so level is always a pure function of lifetime XP (no separate mutable "level" field
  to drift out of sync).

## 9.2 Career ranks

| Rank | Unlocks at level |
|---|---|
| Student | 1 |
| Intern | 3 |
| Assistant Breeder | 6 |
| Research Associate | 10 |
| Scientist | 15 |
| Senior Scientist | 21 |
| Chief Plant Breeder | 28 |

Ranks are cosmetic + narrative today; the roadmap ties them to unlocking crops/labs (chickpea and
cotton already gate at unlock level 2 in `data/crops.ts` as a first example) and teacher-visible
titles on the class leaderboard.

## 9.3 Badges

10 badges across 5 categories (breeding, genetics, research, games, career) — see
`data/gamification.ts` for the full list (First Cross, Variety Releaser, Survivor, Gene Hunter,
Gene Detective, Statistician, Polyglot Breeder, Crop Explorer, Game Champion, Published
Researcher). Each has a concrete, checkable unlock condition wired directly into the module that
earns it (e.g. `unlockBadge("survivor")` fires in the Breeder Simulator only if the released
program's event log contains a high-severity event).

## 9.4 Missions

Daily missions (reset conceptually every day — production adds a cron/edge-function reset;
today's build allows re-claiming once per session) reward small, frequent actions: perform a
cross, run a gene edit, answer 3 viva questions. Weekly missions reward larger milestones: release
a variety, solve a detective case, run a statistical analysis. Teachers can author course-scoped
missions in addition to the global set (see `assignments`/`missions.course_id` in the schema).

## 9.5 Publications & grants

Career Mode lets a student "submit a publication" or "apply for a grant" — a lightweight
abstraction over real research milestones (in production, these are earned automatically when a
released variety or completed analysis meets a quality bar, rather than self-declared) that grant
XP and populate the student's in-app CV, mirroring how a real research career accumulates.

## 9.6 Leaderboards (roadmap)

Per-course and global leaderboards ranked by XP/level, realized via Supabase Realtime subscriptions
on `xp_events` aggregates. Deliberately not in the MVP build to keep the local-first, single-device
experience simple; the schema (`xp_events`, `profiles`, `course_enrollments`) already supports it.

## 9.7 Design rationale

The gamification layer is built to reward **process, not just correctness** — XP flows for
attempting a viva question (even if wrong), for recording a field-notebook observation, and for
surviving a field event, not only for "winning." This mirrors real scientific practice, where
careful process and honest negative results have value, and avoids punishing the experimentation
and mistake-making the product's learning philosophy is built around.
