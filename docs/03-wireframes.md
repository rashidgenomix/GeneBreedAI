# 3. UI Wireframes

Low-fidelity wireframes for the core screens. (The implemented React app in `frontend/` reflects
these layouts — see screenshots referenced in `08-screens.md`.)

## 3.1 App shell (all screens)

```
┌───────────────┬──────────────────────────────────────────────────────────┐
│  🧬 GeneBreed  │  Lvl 4 · Intern   [██████████░░░░░░░] 120/300 XP   🌙/☀ │
│  AI            ├──────────────────────────────────────────────────────────┤
│                │                                                          │
│  🌱 Breeder     │                                                          │
│  🧬 Gene Lab    │                    < module content >                   │
│  🔍 Detective   │                                                          │
│  🎓 Supervisor  │                                                          │
│  🗣 Viva        │                                                          │
│  🎮 Games       │                                                          │
│  🧪 Research    │                                                          │
│  📓 Notebook    │                                                          │
│  🏆 Career      │                                                          │
└───────────────┴──────────────────────────────────────────────────────────┘
```

Persistent left sidebar (collapses to a hamburger drawer on mobile) + persistent top XP bar. Every
module renders inside the same shell so XP/level feedback is always visible.

## 3.2 Home dashboard

```
┌──────────────────────────────────────────────────────────────────────────┐
│  ░░░░░░░░░░░░░░  Welcome back, Intern (Lvl 4)  ░░░░░░░░░░░░░░░░░░░░░░░░░  │
│  🧬 GeneBreed AI — immersive plant breeding & genetics laboratory        │
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
│                                                                          │
│  Modules                                                                │
│  ┌───────────────┐ ┌───────────────┐ ┌───────────────┐                  │
│  │ 🌱 Breeder     │ │ 🧬 Gene Lab    │ │ 🔍 Detective   │  ...           │
│  │ Sim            │ │                │ │                │                  │
│  └───────────────┘ └───────────────┘ └───────────────┘                  │
└──────────────────────────────────────────────────────────────────────────┘
```

## 3.3 Breeder Simulator — Parent Explorer / Comparison

```
┌──────────────────────────────────────────────────────────────────────────┐
│  1.Crop  2.[Parents]  3.Method  4.Grow&Select  5.Release                 │
├───────────────────────────┬──────────────────────────────────────────────┤
│  PARENT A                 │  PARENT B                                    │
│  ○ Norin 10 Derivative     │  ○ Sonalika                                  │
│  ○ Sonalika                │  ● PBW-343              (selected)          │
│  ○ PBW-343                 │  ○ Lr34 Donor Line                          │
│  ○ Lr34 Donor Line         │  ○ Drysdale                                 │
│  ○ Drysdale                │  ○ Local Landrace                           │
│  ○ Local Landrace          │                                              │
├───────────────────────────┴──────────────────────────────────────────────┤
│  Trait Comparison: Norin 10 Derivative  vs  PBW-343                      │
│  Yield          [███████░░░]        [██████████░]                       │
│  Plant Height   [██░░░░░░░░]        [█████░░░░░░]                       │
│  Disease Res.   [████░░░░░░]        [███░░░░░░░░]                       │
│  ...                                                                     │
│                                        [ Choose Breeding Method → ]      │
└──────────────────────────────────────────────────────────────────────────┘
```

## 3.4 Breeder Simulator — Generation / Field Event view

```
┌──────────────────────────────────────────────────────────────────────────┐
│ ⚠ Field Event: Disease Outbreak  [high]                                  │
│   A fungal epidemic sweeps the trial block...                           │
├──────────────────────────────────────────────────────────────────────────┤
│ Generation F3          Method: Pedigree · progress 3/6                   │
│                              [Auto-select Top 4] [Advance Generation]    │
│ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐                              │
│ │F3-a1 72│ │F3-a2 65│ │F3-a3 80│ │F3-a4 58│   ← click to select/deselect │
│ │[bars]  │ │[bars]  │ │[bars]  │ │[bars]  │                              │
│ └────────┘ └────────┘ └────────┘ └────────┘   (12 individuals per gen)  │
└──────────────────────────────────────────────────────────────────────────┘
```

## 3.5 Gene Function Discovery Lab

```
┌───────────────────┬──────────────────────────────────────────────────────┐
│ CHROMOSOME MAP     │  FT — FLOWERING LOCUS T                    [Chr 7]  │
│ ▸ FT   Chr7 23.4Mb │  Mobile florigen signal...                          │
│ ▸ Rht-B1 Chr4       │  Pathway: Photoperiod / Flowering time              │
│                     │  Expression: Leaf 90% ▓▓▓▓▓▓▓▓▓░  Apex 30% ▓▓▓░░   │
│                     │  Wild-type phenotype: flowers on schedule...        │
│                     │  [Knockout][Overexpr.][RNAi][CRISPR]  [Run Exp.]    │
│                     │  → Observed: severe late flowering...               │
└───────────────────┴──────────────────────────────────────────────────────┘
```

## 3.6 Career Mode

```
┌──────────────────────────────────────────────────────────────────────────┐
│ Career Ladder                                                            │
│ [Student✓][Intern✓][Assistant Breeder][Research Assoc.][Scientist]...    │
│                                                                          │
│ Level 4    Total XP 620    Publications 1    Grants 0                   │
│                                                                          │
│ Missions                          Badges (4/10)                        │
│ ☐ Perform a Cross      +20XP      🏅 First Cross    🏅 Gene Hunter      │
│ ☑ Run a Gene Edit       done      ⬜ Survivor        ⬜ Detective        │
└──────────────────────────────────────────────────────────────────────────┘
```

## 3.7 Design tokens

- **Color:** emerald/lime green primary (growth, biology), amber for warnings/field events, rose
  for failure states, sky for informational tags.
- **Typography:** Inter, system-ui fallback; monospace for genetic/statistical values.
- **Shape language:** large rounded corners (rounded-2xl cards, rounded-full pills/nav) to feel
  approachable rather than clinical.
- **Motion:** subtle leaf-sway and DNA-spin keyframe animations reserved for hero/empty states;
  functional UI transitions stay under 200ms.
