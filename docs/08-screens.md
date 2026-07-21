# 8. Screen-by-Screen Design

For each screen: purpose, key components, states, and primary interactions.
Implementation: `frontend/src/pages` and `frontend/src/modules/*`.

## 8.1 Home Dashboard (`/`, `pages/Home.tsx`)

- **Purpose:** orientation hub — shows career rank/level and links into all 9 modules.
- **Components:** gradient hero banner (rank + level), 3×3 module card grid.
- **States:** none beyond level display (reads from `useLevelInfo()`).
- **Interactions:** click any module card → navigate to that module's route.

## 8.2 AI Plant Breeder Simulator (`/breeder`)

- **Purpose:** the flagship experiential loop — parent selection through variety release.
- **Components:** 5-step `Stepper`; `CropStep` (6 crop cards); `ParentStep` (two scrollable
  germplasm lists + live `TraitBar` comparison); `MethodStep` (10 method cards with
  advantages/limitations); `GenerationsStep` (population grid of individual cards, each showing a
  score pill and 3 trait bars, click-to-select, "Auto-select Top 4", field-event banner);
  `ReleaseStep` (best-line trait summary + naming input).
- **States:** `crop → parents → method → generations → release`, plus a terminal "released" success
  card. Field events fire pseudo-randomly on every "Advance Generation" click.
- **Interactions:** select crop → select 2 parents → compare traits → pick method → hybridize →
  toggle-select individuals each generation → advance → (repeat until stability) → name & release.
- **Gamification hooks:** +25 XP first cross (badge: First Cross), +15 XP per generation
  advanced, +50 XP + score-based bonus on release (badge: Variety Releaser; badge: Survivor if a
  high-severity event was survived).

## 8.3 Gene Function Discovery Lab (`/gene-lab`)

- **Purpose:** discover gene function through experimentation rather than memorization.
- **Components:** crop filter chips; chromosome-map list of gene cards (symbol, chromosome,
  position); gene detail panel (function, pathway, expression bar chips, wild-type phenotype card,
  4 edit-type buttons, "Run Experiment", result card with phenotype/mechanism/yield-impact pill and
  a reflective prompt).
- **States:** no crop selected → crop selected/no gene → gene selected/no edit → edit run/result
  shown.
- **Interactions:** pick crop → pick gene → pick edit type → run → read outcome → (implicitly)
  carry the reflection into the Research Supervisor.
- **Gamification hooks:** +20 XP per experiment (badge: Gene Hunter).

## 8.4 AI Gene Detective (`/detective`)

- **Purpose:** diagnostic reasoning practice — evidence gathering then hypothesis testing.
- **Components:** case list (title + symptom bullets); case detail (symptoms card, clue-tool grid
  that reveals text on click, hypothesis option list, verdict card with explanation + culprit
  reveal).
- **States:** case list → case open, clues progressively revealed → hypothesis chosen →
  correct/incorrect verdict shown.
- **Interactions:** pick a case → click each tool to reveal its clue → choose the best-supported
  hypothesis from 4 options → read the evidence-grounded explanation.
- **Gamification hooks:** +35 XP correct (badge: Gene Detective), +5 XP attempt.

## 8.5 AI Research Supervisor (`/supervisor`)

- **Purpose:** Socratic defense of a decision or hypothesis — the connective-tissue module that
  can follow any other module.
- **Components:** claim input; running transcript of supervisor question → student response →
  reasoning-strength pill + feedback; active-question card with textarea, "Respond", and "Hint".
- **States:** no claim yet → active dialogue (repeats indefinitely, prompts drawn from 5
  categories without immediate repeats).
- **Interactions:** state a claim → answer a Socratic prompt → get reasoning-strength feedback →
  next prompt (optionally request a hint first).
- **Gamification hooks:** +3 to +15 XP per turn scaled by reasoning strength.

## 8.6 AI Viva Examiner (`/viva`)

- **Purpose:** adaptive oral-exam-style assessment.
- **Components:** difficulty/score/streak pills; question card (topic, MC options, correct/
  incorrect highlight on submit, follow-up text, "Next Question").
- **States:** start screen → active question → answered (follow-up shown) → next question with
  recalculated difficulty.
- **Interactions:** answer → read follow-up → continue; difficulty adapts up on a streak, down on
  a miss.
- **Gamification hooks:** +2 XP attempt, +10 to +25 XP scaled by difficulty on correct answers.

## 8.7 Genetics Games (`/games`)

- **Purpose:** fast, replayable drills.
- **Components:** game hub grid (8 games, 2 playable + 6 "coming soon"); **Trait Prediction**
  (Punnett-ratio multiple choice, round counter); **Gene Matching** (memory-match grid pairing gene
  symbols to function snippets).
- **States:** hub → active game → round/game complete.
- **Interactions:** pick a game → play rounds → track score; badge on a perfect run.
- **Gamification hooks:** +10-12 XP per correct action; badge: Game Champion.

## 8.8 Virtual Research Lab (`/research-lab`)

- **Purpose:** real statistical analysis over generated datasets.
- **Components:** analysis hub (5 analyses, 2 implemented); **Heritability & Genetic Advance**
  (histogram of a generated F2 population, computed Vp/Vg/H²/genetic-advance stat tiles,
  interpretation card); **ANOVA (RBD)** (data table, full ANOVA table with F-values, interpretation
  card).
- **States:** hub → analysis view → "Compute Results" / "Submit Interpretation" pressed.
- **Interactions:** regenerate dataset → compute → read interpretation guidance.
- **Gamification hooks:** +30 XP per completed analysis (badge: Statistician).

## 8.9 Field Notebook (`/notebook`)

- **Purpose:** structured observation logging, mirroring a real field notebook.
- **Components:** entry form (crop select, observation-type select, value, image attach, notes);
  entry list (thumbnail, type, date, value, notes, delete); auto-generated summary report toggle.
- **States:** empty → entries listed → report shown/hidden.
- **Interactions:** fill form → save → (optionally) generate report → delete an entry.
- **Gamification hooks:** +5 XP per observation recorded.

## 8.10 Career Mode (`/career`)

- **Purpose:** the meta-progression view tying every module's XP together.
- **Components:** career ladder (7 ranks, current rank highlighted); stat tiles (level, XP,
  publications, grants); "Submit Publication" / "Apply for Grant" actions; missions list
  (daily/weekly, claimable); badge grid (10 badges, locked/unlocked states).
- **States:** reflects `gameStore` — always live, no separate empty state.
- **Interactions:** claim a mission reward → submit a publication/grant → view badge/rank
  progress.
