-- =============================================
-- STEP 1: Create enrollments table
-- =============================================

create table enrollments (
  id         uuid primary key default gen_random_uuid(),
  student_id uuid references users(id) on delete cascade,
  subject_id uuid references subjects(id) on delete cascade,
  created_at timestamp with time zone default now(),
  unique(student_id, subject_id) -- prevent duplicate enrollments
);

-- RLS for enrollments
alter table enrollments enable row level security;

create policy "Student can read own enrollments"
  on enrollments for select
  using (auth.uid() = student_id);

create policy "Admin can manage enrollments"
  on enrollments for all
  using (auth.uid() = student_id);


-- =============================================
-- STEP 2: Auto-absent PostgreSQL function
-- Marks absent for all enrolled students who
-- didn't scan QR after lecture expires
-- =============================================

create or replace function mark_absent_students()
returns void as $$
declare
  lec record;
  stu record;
begin
  -- Loop through all expired lectures
  for lec in
    select id, subject_id
    from lectures
    where expires_at < now()
  loop
    -- Loop through all students enrolled in that subject
    for stu in
      select student_id
      from enrollments
      where subject_id = lec.subject_id
    loop
      -- Insert absent only if no record exists for this student+lecture
      insert into attendance (lecture_id, student_id, status)
      values (lec.id, stu.student_id, 'absent')
      on conflict (lecture_id, student_id) do nothing;
    end loop;
  end loop;
end;
$$ language plpgsql security definer;


-- =============================================
-- STEP 3: Schedule with pg_cron (runs every minute)
-- Enable pg_cron first:
-- Go to Supabase → Database → Extensions → enable "pg_cron"
-- Then run the line below
-- =============================================

select cron.schedule(
  'mark-absent-every-minute',
  '* * * * *',
  $$ select mark_absent_students(); $$
);
