# 6. API Structure

Production GeneBreed AI uses Supabase's auto-generated PostgREST API for straightforward CRUD
(gated by RLS, see `02-database-schema.md`) plus a small set of custom Edge Functions for anything
that needs server-side logic or must call an external AI API.

## 6.1 PostgREST (auto-generated, RLS-enforced)

Standard REST-over-Postgres access, used directly by the client via the Supabase JS SDK:

```
GET    /rest/v1/crops?select=*,traits(*),germplasm(*)
GET    /rest/v1/breeding_programs?student_id=eq.<uid>
POST   /rest/v1/breeding_programs
PATCH  /rest/v1/breeding_programs?id=eq.<id>
POST   /rest/v1/program_generations
POST   /rest/v1/program_individuals
POST   /rest/v1/gene_edit_experiments
POST   /rest/v1/detective_attempts
POST   /rest/v1/notebook_entries
GET    /rest/v1/notebook_entries?student_id=eq.<uid>&order=observation_date.desc
POST   /rest/v1/game_scores
POST   /rest/v1/research_analyses
```

## 6.2 Edge Functions (custom, `supabase/functions/*`)

| Function | Method | Purpose |
|---|---|---|
| `ai-supervisor` | POST | Given a student claim + conversation history, calls GPT with the Research Supervisor system prompt (see `07-ai-workflow.md`) and returns the next Socratic question + a reasoning-strength assessment. Never returns a direct answer. |
| `ai-viva` | POST | Generates/selects the next adaptive viva question given the running difficulty and answer history; can fall back to the static question bank if the AI call fails. |
| `ai-detective-hint` | POST | Reveals the next clue in a mystery case and, once enough clues are gathered, evaluates the student's proposed hypothesis via GPT with a rubric grounded in `detective_cases.explanation`. |
| `ai-image` | POST | Generates an illustrative image of a mutant phenotype or gene-network diagram via an image-generation API, cached in Supabase Storage keyed by (gene_id, edit_type). |
| `ai-voice-transcribe` | POST | Speech-to-text for spoken viva answers. |
| `ai-voice-speak` | POST | Text-to-speech for the AI examiner reading a question aloud. |
| `score-breeding-program` | POST | Server-side recomputation of a submitted program's release score and pedigree, so client-side XP claims can't be spoofed; writes `xp_events` and evaluates badge conditions. |
| `generate-class-report` | POST | Teacher-triggered aggregate report (PDF/CSV) across a course's students for a date range or module. |
| `sync-reference-data` | POST (admin only) | Re-syncs the canonical `frontend/src/data/*.ts` content into `crops`/`traits`/`germplasm`/`genes`/`detective_cases` tables after a content update. |

## 6.3 Request/response shape example

`POST /functions/v1/ai-supervisor`

```json
// Request
{
  "sessionId": "uuid",
  "studentClaim": "I chose Drysdale as a parent because it's drought tolerant",
  "history": [
    { "question": "Why did you choose this parent?", "response": "..." }
  ]
}

// Response
{
  "question": "What evidence directly supports your hypothesis?",
  "category": "evidence",
  "priorTurnAssessment": { "strength": "developing", "feedback": "..." }
}
```

## 6.4 Authentication

All PostgREST and Edge Function calls carry the Supabase session JWT (from Google OAuth login) in
the `Authorization: Bearer <token>` header; RLS policies read `auth.uid()` from that JWT. Edge
Functions additionally validate a `role` claim for teacher/admin-only endpoints
(`generate-class-report`, `sync-reference-data`).

## 6.5 Rate limiting & cost control

AI-calling Edge Functions apply a per-student, per-day quota (tracked in a lightweight
`ai_usage_counters` table) to bound OpenAI API spend; when a quota is hit, the client transparently
falls back to the static rule-based question/hint banks already implemented in the frontend
(`data/supervisorQuestions.ts`, `data/vivaQuestions.ts`) so the experience degrades gracefully
rather than failing.
