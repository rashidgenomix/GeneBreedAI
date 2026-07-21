# 11. Technology Stack

## 11.1 What's implemented today

| Layer | Choice | Why |
|---|---|---|
| Frontend framework | React 19 + TypeScript | Component model fits 9 distinct modules cleanly; TS catches the many cross-referenced data-model shapes (crops/traits/genes) at compile time. |
| Build tool | Vite | Fast HMR for iterating on a visually heavy app. |
| Styling | Tailwind CSS v4 | Utility classes kept every module's markup self-contained without a growing global stylesheet; first-class dark-mode variant support. |
| Routing | React Router v7 | Simple, well-understood route tree (see `05-navigation-map.md`). |
| State management | Zustand (+ `persist` middleware) | Minimal boilerplate for two concerns: game progress (XP/badges/programs) and field-notebook entries; `localStorage` persistence gives offline-friendly progress with zero backend for the MVP. |
| Charts | Recharts | Histogram (heritability) and bar visualizations in the Virtual Research Lab. |
| Icons | lucide-react | Consistent icon set across all modules, including dynamic icon lookup for data-driven field events/clues. |
| Animation | Tailwind keyframes + (available) Framer Motion | Lightweight leaf-sway/DNA-spin/pulse-glow accents without a heavy animation dependency for most UI. |

## 11.2 Planned production stack

| Layer | Choice | Notes |
|---|---|---|
| Mobile | Flutter | Shares the Supabase backend and Edge Function API; native performance for offline field-notebook photo capture. |
| Backend / BaaS | Supabase | Postgres + Auth + Storage + Realtime + Edge Functions (Deno) in one platform, avoiding a bespoke ops burden for a small team. |
| Database | PostgreSQL | See `02-database-schema.md`; row-level security is a first-class fit for a multi-tenant (institution/course) education product. |
| Auth | Supabase Auth, Google OAuth | Matches university SSO expectations and the explicit requirement for Google Login. |
| AI | OpenAI GPT API (chat), image generation API, speech-to-text/TTS | See `07-ai-workflow.md` for the persona/prompt design; called only from Edge Functions, never the client. |
| Hosting | Vercel or Netlify (frontend), Supabase Cloud (backend) | Zero-ops static hosting + managed Postgres; see `12-deployment.md`. |
| CI | GitHub Actions | Typecheck + build on every PR; deploy previews per branch. |

## 11.3 Why not [alternative]?

- **Firebase vs Supabase:** Supabase's native Postgres (vs Firestore's NoSQL) is a much better fit
  for the highly relational pedigree/course/grading data model in `02-database-schema.md`, and its
  RLS model maps directly onto "a student can only see their own program" without bespoke security
  rules.
- **Flutter-only vs React-web-first:** the product's richest interactions (trait-bar comparisons,
  chromosome maps, data tables) are naturally desktop/web-shaped for a university course context;
  Flutter is scoped in for a companion mobile app (notebook capture, quick viva/games sessions) once
  the web MVP's data model has stabilized, rather than building both simultaneously.
- **Redux/Context vs Zustand:** the state surface (game progress, notebook) is small and doesn't
  need Redux's ceremony; Zustand's `persist` middleware directly solved the "must work offline"
  requirement with a few lines of code.
