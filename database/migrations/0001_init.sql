-- GeneBreed AI — core PostgreSQL schema (Supabase-compatible)
-- Assumes Supabase auth.users as the identity source; profiles extends it 1:1.
-- Run migrations 0001..000N in order via the Supabase CLI or psql.

create extension if not exists "pgcrypto";

-- ============================================================
-- IDENTITY & ROLES
-- ============================================================

create type user_role as enum ('student', 'teacher', 'admin');

create table profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null,
  role user_role not null default 'student',
  institution text,
  avatar_url text,
  created_at timestamptz not null default now()
);

create table courses (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references profiles (id) on delete cascade,
  title text not null,
  description text,
  join_code text unique not null,
  created_at timestamptz not null default now()
);

create table course_enrollments (
  course_id uuid not null references courses (id) on delete cascade,
  student_id uuid not null references profiles (id) on delete cascade,
  enrolled_at timestamptz not null default now(),
  primary key (course_id, student_id)
);

-- ============================================================
-- CROP / GERMPLASM / TRAIT REFERENCE DATA (seeded, mostly read-only in-app)
-- ============================================================

create table crops (
  id text primary key, -- 'wheat' | 'rice' | 'maize' | 'cotton' | 'tomato' | 'chickpea'
  name text not null,
  scientific_name text not null,
  chromosome_number int not null,
  genome_size_mb numeric not null,
  description text,
  unlock_level int not null default 1
);

create table traits (
  id text not null,          -- e.g. 'yield', 'plant_height'
  crop_id text not null references crops (id) on delete cascade,
  name text not null,
  description text,
  inheritance text not null check (inheritance in ('monogenic-dominant', 'monogenic-recessive', 'polygenic')),
  unit text not null,
  loci int,
  direction text not null check (direction in ('higher-better', 'lower-better', 'target-value')),
  target_value numeric,
  min_value numeric not null,
  max_value numeric not null,
  primary key (crop_id, id)
);

create table germplasm (
  id text primary key,
  crop_id text not null references crops (id) on delete cascade,
  name text not null,
  origin text,
  description text,
  trait_values jsonb not null default '{}',  -- { trait_id: 0-1 normalized value }
  genotype jsonb not null default '{}',       -- { locus: "Rr" }
  tags text[] not null default '{}'
);

create table environments (
  id text primary key,
  crop_id text not null references crops (id) on delete cascade,
  name text not null,
  description text,
  stressors text[] not null default '{}'
);

create table genes (
  id text primary key,
  crop_id text not null references crops (id) on delete cascade,
  symbol text not null,
  name text not null,
  chromosome int not null,
  position_label text,
  gene_function text,
  pathway text,
  protein_family text,
  normal_phenotype text,
  expression jsonb not null default '[]',      -- [{ tissue, level }]
  edit_outcomes jsonb not null default '[]'    -- [{ edit, phenotype, mechanism, yield_impact }]
);

create table field_event_types (
  id text primary key, -- 'disease-outbreak', 'heat-stress', ...
  name text not null,
  description text,
  severity text not null check (severity in ('low', 'medium', 'high')),
  favors_trait_ids text[] not null default '{}'
);

create table breeding_method_types (
  id text primary key, -- 'pedigree', 'bulk', ...
  name text not null,
  summary text,
  advantages text[] not null default '{}',
  limitations text[] not null default '{}',
  generations_to_stability int not null,
  cost_multiplier numeric not null default 1,
  speed_multiplier numeric not null default 1
);

-- ============================================================
-- MODULE 1: BREEDING PROGRAMS
-- ============================================================

create table breeding_programs (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references profiles (id) on delete cascade,
  crop_id text not null references crops (id),
  method_id text not null references breeding_method_types (id),
  name text not null,
  parent_a_id text not null references germplasm (id),
  parent_b_id text not null references germplasm (id),
  current_generation int not null default 1,
  released boolean not null default false,
  released_variety_name text,
  final_score int,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table program_generations (
  id uuid primary key default gen_random_uuid(),
  program_id uuid not null references breeding_programs (id) on delete cascade,
  generation_number int not null,
  field_event_id text references field_event_types (id),
  decision_notes text,
  created_at timestamptz not null default now(),
  unique (program_id, generation_number)
);

create table program_individuals (
  id uuid primary key default gen_random_uuid(),
  generation_id uuid not null references program_generations (id) on delete cascade,
  label text not null,
  parent_a_individual_id uuid references program_individuals (id),
  parent_b_individual_id uuid references program_individuals (id),
  trait_values jsonb not null default '{}',
  genotype jsonb not null default '{}',
  heterozygosity numeric not null default 0,
  selected boolean not null default false,
  score int
);

-- ============================================================
-- MODULE 2: GENE EDITING EXPERIMENTS
-- ============================================================

create table gene_edit_experiments (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references profiles (id) on delete cascade,
  gene_id text not null references genes (id),
  edit_type text not null check (edit_type in ('knockout', 'overexpression', 'rnai', 'crispr-edit')),
  observed_phenotype text,
  reflection_response text,
  created_at timestamptz not null default now()
);

-- ============================================================
-- MODULE 3: GENE DETECTIVE
-- ============================================================

create table detective_cases (
  id text primary key,
  crop_id text references crops (id),
  title text not null,
  symptoms text[] not null default '{}',
  clues jsonb not null default '[]',           -- [{ tool, text }]
  culprit_gene text,
  correct_hypothesis text not null,
  distractor_hypotheses text[] not null default '{}',
  explanation text
);

create table detective_attempts (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references profiles (id) on delete cascade,
  case_id text not null references detective_cases (id),
  chosen_hypothesis text not null,
  correct boolean not null,
  clues_revealed text[] not null default '{}',
  created_at timestamptz not null default now()
);

-- ============================================================
-- MODULE 4/5: AI SUPERVISOR & VIVA SESSIONS
-- (message logs; production system additionally calls the GPT API — see docs/06-ai-workflow.md)
-- ============================================================

create table supervisor_sessions (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references profiles (id) on delete cascade,
  topic text not null,
  created_at timestamptz not null default now()
);

create table supervisor_turns (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references supervisor_sessions (id) on delete cascade,
  prompt_category text not null,
  question text not null,
  student_response text not null,
  reasoning_strength text check (reasoning_strength in ('weak', 'developing', 'strong')),
  feedback text,
  created_at timestamptz not null default now()
);

create table viva_sessions (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references profiles (id) on delete cascade,
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  final_difficulty int
);

create table viva_responses (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references viva_sessions (id) on delete cascade,
  question_id text not null,
  difficulty int not null,
  selected_index int not null,
  correct boolean not null,
  created_at timestamptz not null default now()
);

-- ============================================================
-- MODULE 6: GENETICS GAMES
-- ============================================================

create table game_scores (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references profiles (id) on delete cascade,
  game_id text not null, -- 'trait-prediction' | 'gene-matching' | ...
  score int not null,
  max_score int not null,
  duration_seconds int,
  created_at timestamptz not null default now()
);

-- ============================================================
-- MODULE 7: VIRTUAL RESEARCH LAB
-- ============================================================

create table research_analyses (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references profiles (id) on delete cascade,
  analysis_type text not null check (analysis_type in ('heritability', 'anova', 'line-x-tester', 'qtl', 'gwas')),
  dataset_seed int,
  results jsonb not null default '{}',
  interpretation text,
  created_at timestamptz not null default now()
);

-- ============================================================
-- MODULE 8: FIELD NOTEBOOK
-- ============================================================

create table notebook_entries (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references profiles (id) on delete cascade,
  crop_id text references crops (id),
  observation_date date not null default current_date,
  observation_type text not null check (observation_type in ('flowering', 'disease-score', 'yield', 'height', 'general')),
  value text not null,
  notes text,
  image_url text,
  created_at timestamptz not null default now()
);

-- ============================================================
-- MODULE 9: CAREER MODE / GAMIFICATION
-- ============================================================

create table badges (
  id text primary key,
  name text not null,
  description text,
  icon text,
  category text not null check (category in ('breeding', 'genetics', 'research', 'games', 'career'))
);

create table user_badges (
  student_id uuid not null references profiles (id) on delete cascade,
  badge_id text not null references badges (id) on delete cascade,
  unlocked_at timestamptz not null default now(),
  primary key (student_id, badge_id)
);

create table xp_events (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references profiles (id) on delete cascade,
  amount int not null,
  reason text not null,
  created_at timestamptz not null default now()
);

create table missions (
  id text primary key,
  title text not null,
  description text,
  xp int not null,
  type text not null check (type in ('daily', 'weekly')),
  course_id uuid references courses (id) -- null = global mission available to everyone
);

create table user_missions (
  student_id uuid not null references profiles (id) on delete cascade,
  mission_id text not null references missions (id) on delete cascade,
  completed_at timestamptz not null default now(),
  primary key (student_id, mission_id, completed_at)
);

create table publications (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references profiles (id) on delete cascade,
  title text not null,
  summary text,
  related_program_id uuid references breeding_programs (id),
  created_at timestamptz not null default now()
);

create table grants (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references profiles (id) on delete cascade,
  title text not null,
  amount_xp int not null default 30,
  created_at timestamptz not null default now()
);

-- ============================================================
-- TEACHER TOOLS
-- ============================================================

create table assignments (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references courses (id) on delete cascade,
  title text not null,
  description text,
  module text not null, -- 'breeder' | 'gene-lab' | 'detective' | ... matches frontend route
  due_at timestamptz,
  created_at timestamptz not null default now()
);

create table assignment_submissions (
  id uuid primary key default gen_random_uuid(),
  assignment_id uuid not null references assignments (id) on delete cascade,
  student_id uuid not null references profiles (id) on delete cascade,
  reference_id uuid, -- points at a breeding_programs.id, research_analyses.id, etc. (polymorphic by module)
  submitted_at timestamptz not null default now(),
  grade numeric,
  feedback text
);

create table exams (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references courses (id) on delete cascade,
  title text not null,
  question_ids text[] not null default '{}', -- references viva question bank ids
  created_at timestamptz not null default now()
);

-- ============================================================
-- INDEXES
-- ============================================================

create index on breeding_programs (student_id);
create index on program_generations (program_id);
create index on program_individuals (generation_id);
create index on gene_edit_experiments (student_id);
create index on detective_attempts (student_id);
create index on viva_responses (session_id);
create index on game_scores (student_id, game_id);
create index on notebook_entries (student_id, crop_id);
create index on xp_events (student_id);
create index on user_missions (student_id);
create index on course_enrollments (student_id);
create index on assignment_submissions (assignment_id, student_id);
