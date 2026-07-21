# GeneBreed AI — Design & Architecture Documentation

GeneBreed AI is an AI-powered interactive learning platform for undergraduate Agriculture
students studying Plant Breeding and Genetics. It is **not** a chatbot or note-generator — it is
an immersive virtual laboratory where students learn by experimenting, making mistakes,
running breeding programs, performing genetic analyses, and solving real agricultural problems.
The AI acts as mentor, research supervisor, evaluator, and scientific collaborator.

## Document index

| # | Document | Contents |
|---|----------|----------|
| 1 | [01-architecture.md](01-architecture.md) | Complete system architecture |
| 2 | [02-database-schema.md](02-database-schema.md) | Database schema (see also `database/migrations/*.sql`) |
| 3 | [03-wireframes.md](03-wireframes.md) | UI wireframes |
| 4 | [04-user-flows.md](04-user-flows.md) | User flow |
| 5 | [05-navigation-map.md](05-navigation-map.md) | Navigation map |
| 6 | [06-api-structure.md](06-api-structure.md) | API structure |
| 7 | [07-ai-workflow.md](07-ai-workflow.md) | AI workflow |
| 8 | [08-screens.md](08-screens.md) | Screen-by-screen design |
| 9 | [09-gamification.md](09-gamification.md) | Gamification system |
| 10 | [10-learning-outcomes.md](10-learning-outcomes.md) | Learning outcomes |
| 11 | [11-tech-stack.md](11-tech-stack.md) | Technology stack |
| 12 | [12-deployment.md](12-deployment.md) | Deployment strategy |
| 13 | [13-roadmap.md](13-roadmap.md) | Future roadmap |

## What has been built so far

The `frontend/` directory contains a working React + TypeScript implementation of the product
vision described here:

- A fully playable **Module 1: AI Plant Breeder Simulator** — 6 crops, real germplasm/trait data,
  10 breeding methods, hybridization, multi-generation selection, 10 random field events, and
  variety release, all backed by a small teachable genetics engine (`src/lib/genetics.ts`).
- A functional **Module 2: Gene Function Discovery Lab** — gene cards, expression profiles, and a
  gene editing simulator (knockout / overexpression / RNAi / CRISPR) with real phenotype outcomes.
- A functional **Module 3: AI Gene Detective** with two full mystery cases and an evidence-gathering
  + hypothesis-testing loop.
- A functional **Module 4: AI Research Supervisor** Socratic-questioning loop (rule-based today;
  designed to be swapped for the GPT API per `07-ai-workflow.md`).
- A functional **Module 5: AI Viva Examiner** with adaptive difficulty and branching follow-ups.
- **Module 6: Genetics Games** — two fully playable games (Trait Prediction, Gene Matching) plus a
  hub scaffold for the remaining six.
- A functional **Module 7: Virtual Research Lab** — real heritability/genetic-advance and ANOVA
  calculators over generated datasets.
- A functional **Module 8: Field Notebook** with image attachments and auto-generated reports.
- A functional **Module 9: Career Mode** with the full rank ladder, missions, and badges.
- A full **gamification engine** (XP, levels, badges, career ranks) wired through every module.
- The complete **PostgreSQL/Supabase schema** in `database/migrations/`.

This is a learning-platform MVP intended to demonstrate the full experience end-to-end on one
device with local persistence; `07-ai-workflow.md`, `06-api-structure.md`, and `12-deployment.md`
describe the path to the full multi-user, cloud-backed product.
