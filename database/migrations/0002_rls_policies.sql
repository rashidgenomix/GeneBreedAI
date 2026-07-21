-- Row Level Security policies (Supabase auth.uid() based).
-- Reference tables (crops, traits, germplasm, genes, badges, missions, etc.) are readable
-- by any authenticated user and writable only by admins via the service role key.

alter table profiles enable row level security;
alter table courses enable row level security;
alter table course_enrollments enable row level security;
alter table breeding_programs enable row level security;
alter table program_generations enable row level security;
alter table program_individuals enable row level security;
alter table gene_edit_experiments enable row level security;
alter table detective_attempts enable row level security;
alter table supervisor_sessions enable row level security;
alter table supervisor_turns enable row level security;
alter table viva_sessions enable row level security;
alter table viva_responses enable row level security;
alter table game_scores enable row level security;
alter table research_analyses enable row level security;
alter table notebook_entries enable row level security;
alter table user_badges enable row level security;
alter table xp_events enable row level security;
alter table user_missions enable row level security;
alter table publications enable row level security;
alter table grants enable row level security;
alter table assignments enable row level security;
alter table assignment_submissions enable row level security;
alter table exams enable row level security;

-- Profiles: a user can read/update only their own profile; teachers can read their students' profiles.
create policy "profiles_self_read" on profiles for select using (id = auth.uid());
create policy "profiles_self_update" on profiles for update using (id = auth.uid());
create policy "profiles_teacher_read_students" on profiles for select using (
  exists (
    select 1 from course_enrollments ce
    join courses c on c.id = ce.course_id
    where ce.student_id = profiles.id and c.teacher_id = auth.uid()
  )
);

-- Generic "owner" pattern applied to all per-student tables:
create policy "own_rows_select" on breeding_programs for select using (student_id = auth.uid());
create policy "own_rows_insert" on breeding_programs for insert with check (student_id = auth.uid());
create policy "own_rows_update" on breeding_programs for update using (student_id = auth.uid());

create policy "own_rows_select" on gene_edit_experiments for select using (student_id = auth.uid());
create policy "own_rows_insert" on gene_edit_experiments for insert with check (student_id = auth.uid());

create policy "own_rows_select" on detective_attempts for select using (student_id = auth.uid());
create policy "own_rows_insert" on detective_attempts for insert with check (student_id = auth.uid());

create policy "own_rows_select" on supervisor_sessions for select using (student_id = auth.uid());
create policy "own_rows_insert" on supervisor_sessions for insert with check (student_id = auth.uid());

create policy "own_rows_select" on viva_sessions for select using (student_id = auth.uid());
create policy "own_rows_insert" on viva_sessions for insert with check (student_id = auth.uid());

create policy "own_rows_select" on game_scores for select using (student_id = auth.uid());
create policy "own_rows_insert" on game_scores for insert with check (student_id = auth.uid());

create policy "own_rows_select" on research_analyses for select using (student_id = auth.uid());
create policy "own_rows_insert" on research_analyses for insert with check (student_id = auth.uid());

create policy "own_rows_select" on notebook_entries for select using (student_id = auth.uid());
create policy "own_rows_insert" on notebook_entries for insert with check (student_id = auth.uid());
create policy "own_rows_delete" on notebook_entries for delete using (student_id = auth.uid());

create policy "own_rows_select" on user_badges for select using (student_id = auth.uid());
create policy "own_rows_select" on xp_events for select using (student_id = auth.uid());
create policy "own_rows_select" on user_missions for select using (student_id = auth.uid());
create policy "own_rows_select" on publications for select using (student_id = auth.uid());
create policy "own_rows_select" on grants for select using (student_id = auth.uid());

-- Child tables inherit visibility from their parent program/session via a join check.
create policy "program_generations_via_parent" on program_generations for select using (
  exists (select 1 from breeding_programs p where p.id = program_generations.program_id and p.student_id = auth.uid())
);
create policy "program_individuals_via_parent" on program_individuals for select using (
  exists (
    select 1 from program_generations g
    join breeding_programs p on p.id = g.program_id
    where g.id = program_individuals.generation_id and p.student_id = auth.uid()
  )
);
create policy "supervisor_turns_via_parent" on supervisor_turns for select using (
  exists (select 1 from supervisor_sessions s where s.id = supervisor_turns.session_id and s.student_id = auth.uid())
);
create policy "viva_responses_via_parent" on viva_responses for select using (
  exists (select 1 from viva_sessions s where s.id = viva_responses.session_id and s.student_id = auth.uid())
);

-- Courses: teachers manage their own courses; enrolled students can read them.
create policy "courses_teacher_manage" on courses for all using (teacher_id = auth.uid());
create policy "courses_student_read" on courses for select using (
  exists (select 1 from course_enrollments ce where ce.course_id = courses.id and ce.student_id = auth.uid())
);

create policy "enrollments_self" on course_enrollments for select using (student_id = auth.uid());
create policy "enrollments_teacher_read" on course_enrollments for select using (
  exists (select 1 from courses c where c.id = course_enrollments.course_id and c.teacher_id = auth.uid())
);

-- Assignments & exams: teachers manage; enrolled students read.
create policy "assignments_teacher_manage" on assignments for all using (
  exists (select 1 from courses c where c.id = assignments.course_id and c.teacher_id = auth.uid())
);
create policy "assignments_student_read" on assignments for select using (
  exists (select 1 from course_enrollments ce where ce.course_id = assignments.course_id and ce.student_id = auth.uid())
);

create policy "submissions_student_own" on assignment_submissions for select using (student_id = auth.uid());
create policy "submissions_student_insert" on assignment_submissions for insert with check (student_id = auth.uid());
create policy "submissions_teacher_read" on assignment_submissions for select using (
  exists (
    select 1 from assignments a join courses c on c.id = a.course_id
    where a.id = assignment_submissions.assignment_id and c.teacher_id = auth.uid()
  )
);
create policy "submissions_teacher_grade" on assignment_submissions for update using (
  exists (
    select 1 from assignments a join courses c on c.id = a.course_id
    where a.id = assignment_submissions.assignment_id and c.teacher_id = auth.uid()
  )
);

create policy "exams_teacher_manage" on exams for all using (
  exists (select 1 from courses c where c.id = exams.course_id and c.teacher_id = auth.uid())
);
create policy "exams_student_read" on exams for select using (
  exists (select 1 from course_enrollments ce where ce.course_id = exams.course_id and ce.student_id = auth.uid())
);
