-- =============================================
-- SMART ATTENDANCE SYSTEM - Supabase Schema
-- Paste this entire file in Supabase SQL Editor
-- =============================================


-- 1. USERS TABLE
create table users (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  prn text unique,
  email text unique not null,
  role text not null check (role in ('student', 'teacher', 'admin')),
  created_at timestamp with time zone default now()
);


-- 2. SUBJECTS TABLE
create table subjects (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  teacher_id uuid references users(id) on delete set null,
  created_at timestamp with time zone default now()
);


-- 3. LECTURES TABLE
create table lectures (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid references subjects(id) on delete cascade,
  teacher_id uuid references users(id) on delete cascade,
  date date not null default current_date,
  qr_token text unique not null,
  expires_at timestamp with time zone not null,
  created_at timestamp with time zone default now()
);


-- 4. ATTENDANCE TABLE
create table attendance (
  id uuid primary key default gen_random_uuid(),
  lecture_id uuid references lectures(id) on delete cascade,
  student_id uuid references users(id) on delete cascade,
  status text not null check (status in ('present', 'absent')) default 'present',
  scanned_at timestamp with time zone default now(),
  unique(lecture_id, student_id)  -- prevent duplicate scans
);


-- =============================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================

alter table users enable row level security;
alter table subjects enable row level security;
alter table lectures enable row level security;
alter table attendance enable row level security;


-- USERS policies
create policy "Users can read own data"
  on users for select
  using (auth.uid() = id);

create policy "Admin can manage all users"
  on users for all
  using (
    exists (
      select 1 from users where id = auth.uid() and role = 'admin'
    )
  );


-- SUBJECTS policies
create policy "Anyone authenticated can read subjects"
  on subjects for select
  using (auth.role() = 'authenticated');

create policy "Admin and teacher can manage subjects"
  on subjects for all
  using (
    exists (
      select 1 from users where id = auth.uid() and role in ('admin', 'teacher')
    )
  );


-- LECTURES policies
create policy "Anyone authenticated can read lectures"
  on lectures for select
  using (auth.role() = 'authenticated');

create policy "Teacher can create lectures"
  on lectures for insert
  with check (
    exists (
      select 1 from users where id = auth.uid() and role = 'teacher'
    )
  );


-- ATTENDANCE policies
create policy "Student can insert own attendance"
  on attendance for insert
  with check (auth.uid() = student_id);

create policy "Student can read own attendance"
  on attendance for select
  using (auth.uid() = student_id);

create policy "Teacher can read attendance for their lectures"
  on attendance for select
  using (
    exists (
      select 1 from lectures
      where lectures.id = attendance.lecture_id
      and lectures.teacher_id = auth.uid()
    )
  );

create policy "Admin can read all attendance"
  on attendance for select
  using (
    exists (
      select 1 from users where id = auth.uid() and role = 'admin'
    )
  );


-- =============================================
-- SAMPLE DATA (optional, for testing)
-- =============================================

-- Insert a test admin (change email/password as needed)
-- insert into users (name, email, password, role)
-- values ('Admin', 'admin@school.com', 'admin123', 'admin');

-- Insert a test teacher
-- insert into users (name, prn, email, password, role)
-- values ('Prof. Nutan Wagh', 'TCH001', 'nutan@school.com', 'teacher123', 'teacher');

-- Insert a test student
-- insert into users (name, prn, email, password, role)
-- values ('Dhiraj Suste', '202602070020', 'dhiraj@school.com', 'student123', 'student');
