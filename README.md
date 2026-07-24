# 🧬 GeneBreed AI

An AI-powered interactive learning platform for undergraduate Agriculture students studying
**Plant Breeding and Genetics** — not a chatbot, not a note generator, but an immersive virtual
laboratory where students learn by experimenting, making mistakes, running breeding programs,
performing genetic analysis, and solving real agricultural problems.

## Repository layout

```
frontend/    React + TypeScript + Tailwind web app (the implemented product — see below)
mobile/      Flutter app (Android + iOS) implementing the same 9 modules natively
database/    PostgreSQL/Supabase schema: migrations/0001_init.sql, 0002_rls_policies.sql,
             0003_seed_reference_data.sql
docs/        Full design documentation — architecture, schema, wireframes, user flows,
             navigation map, API structure, AI workflow, screen designs, gamification,
             learning outcomes, tech stack, deployment strategy, roadmap. Start at docs/00-overview.md.
             MOBILE_DEPLOYMENT.md covers Flutter/Codemagic signing and release setup specifically.
codemagic.yaml   Codemagic CI config: android-workflow (APK+AAB) and ios-workflow (IPA).
```

## Quick start (frontend)

```bash
cd frontend
npm install
npm run dev      # http://localhost:5173
npm run build    # production build
```

No backend or API keys are required to run and use every module today — game progress and field
notebook entries persist to `localStorage`. See `docs/07-ai-workflow.md` and `docs/12-deployment.md`
for how this connects to Supabase + the GPT API in production.

## Quick start (mobile)

```bash
cd mobile
flutter pub get
flutter run              # requires a connected device/emulator or iOS Simulator
flutter build apk --release      # signed if android/key.properties is present, debug-signed otherwise
flutter build ipa --release      # requires macOS + Xcode + Apple signing — see docs/MOBILE_DEPLOYMENT.md
```

The `mobile/` app is a from-scratch Flutter port sharing the same crop/gene/breeding-method data
and the same genetics simulation logic as the web app, with local persistence via
`shared_preferences`. See `docs/MOBILE_DEPLOYMENT.md` for the full Codemagic CI/CD and app-signing
walkthrough (Android keystore + iOS App Store Connect automatic signing).

## What's implemented

All 9 modules from the product spec are live and playable:

1. **AI Plant Breeder Simulator** — 6 crops, real germplasm/trait data, 10 breeding methods, 10
   random field events, multi-generation selection, variety release.
2. **Gene Function Discovery Lab** — gene cards + knockout/overexpression/RNAi/CRISPR editing
   simulator with real phenotype outcomes.
3. **AI Gene Detective** — evidence-gathering mystery cases with hypothesis testing.
4. **AI Research Supervisor** — Socratic questioning that never gives answers, only pushes back.
5. **AI Viva Examiner** — adaptive-difficulty oral-exam-style questioning.
6. **Genetics Games** — Trait Prediction and Gene Matching playable now; 6 more scaffolded.
7. **Virtual Research Lab** — real heritability/genetic-advance and ANOVA calculators.
8. **Field Notebook** — observation logging with image attachments and auto-generated reports.
9. **Career Mode** — full XP/level/badge/rank system, missions, publications, and grants.

Read `docs/00-overview.md` for the complete documentation index.
