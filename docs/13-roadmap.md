# 13. Future Roadmap

## 13.1 Near-term (next milestone)

- **Wire up Supabase Auth + persistence.** Move `gameStore`/`notebookStore` from local-only to
  synced-with-Postgres, using the offline-first strategy in `12-deployment.md`.
- **Ship the AI Edge Functions.** Replace the rule-based Research Supervisor/Viva Examiner with the
  GPT-backed personas described in `07-ai-workflow.md`, keeping the current rule-based logic as the
  offline/quota-exceeded fallback rather than deleting it.
- **Teacher Dashboard v1.** Course creation, join codes, mission assignment, and a class progress
  view reading directly from the schema already in place (`courses`, `assignments`,
  `assignment_submissions`).
- **Complete the remaining 6 games and 3 analyses** that currently show "Coming soon" (DNA Puzzle,
  Chromosome Assembly, Mutation Challenge, Breeding Escape Room, Pedigree Puzzle, Genome Mapping;
  Line × Tester, QTL Mapping, GWAS).

## 13.2 Mid-term

- **Leaderboards & live class view**, using Supabase Realtime over `xp_events` — a teacher watching
  a class breed wheat in real time during a lab session.
- **Flutter mobile companion app** focused on Field Notebook (camera capture in the field) and
  quick Viva/Games sessions, sharing the Supabase backend.
- **Content authoring UI** in the Admin Dashboard so instructors can add new crops, germplasm,
  genes, and detective cases without a code change — backed by `sync-reference-data`.
- **Richer genetics engine**: linkage/recombination between loci (currently loci segregate
  independently), epistasis between named genes, and a proper additive-genetic-variance model for
  polygenic traits validated against real heritability estimates from the literature.
- **Breeding Escape Room** as a flagship "boss level" chaining puzzles from multiple modules
  (a detective case unlocks a gene edit, which unlocks a cross, which must survive a field event).

## 13.3 Long-term

- **Multiplayer breeding competitions** — cohorts compete to release the highest-scoring variety
  under shared random field events within a term, with a live leaderboard.
- **Voice-driven Viva Examiner** using the speech-to-text/TTS pipeline in `07-ai-workflow.md`,
  approximating a real oral exam.
- **Genomic Selection & GWAS modules with real public datasets** (e.g. subsets of published wheat/
  rice diversity panels) rather than only generated data, for advanced/graduate coursework.
- **Institutional analytics**: cross-course, cross-institution benchmarking for curriculum
  designers (opt-in, anonymized).
- **Localization** or regional crop/germplasm packs (e.g. sorghum, millet, cassava) for
  non-cereal-focused institutions, using the same `Crop`/`Germplasm`/`Trait` data model already in
  place — adding a crop today is "add one entry to `data/crops.ts`," which the roadmap treats as a
  content, not architecture, task.

## 13.4 Explicitly out of scope for now

- Real-world genomic data pipelines (VCF ingestion, actual SNP arrays) — the pedagogical engine is
  intentionally simplified; a "Pro" research-grade mode is a plausible future fork, not a near-term
  goal.
- Payment/monetization — the roadmap assumes institutional licensing handled outside the app.
