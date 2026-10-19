-- GFG Quiz Arena database setup for Supabase
-- Run this entire script in Supabase Dashboard > SQL Editor.
-- Then create your owner account in Authentication > Users, copy its UUID,
-- and replace OWNER_AUTH_USER_UUID below by running the INSERT statement at the end.

create extension if not exists pgcrypto;

create table if not exists public.owner_accounts (
  user_id uuid primary key references auth.users(id) on delete cascade
);

create table if not exists public.quizzes (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 1 and 120),
  description text not null default '',
  is_published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid not null references public.quizzes(id) on delete cascade,
  question_text text not null check (char_length(question_text) between 1 and 2000),
  options jsonb not null check (jsonb_typeof(options) = 'array' and jsonb_array_length(options) between 2 and 26),
  correct_option_index integer not null check (correct_option_index >= 0),
  timer_seconds integer not null default 30 check (timer_seconds between 5 and 600),
  sort_order integer not null default 1,
  created_at timestamptz not null default now()
);

create table if not exists public.attempts (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid not null references public.quizzes(id) on delete cascade,
  student_name text not null check (char_length(student_name) between 1 and 100),
  department text not null,
  year text not null,
  score integer not null default 0,
  total_questions integer not null,
  accuracy integer not null default 0,
  created_at timestamptz not null default now()
);

create or replace function public.is_quiz_owner()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from public.owner_accounts where user_id = auth.uid());
$$;

alter table public.owner_accounts enable row level security;
alter table public.quizzes enable row level security;
alter table public.questions enable row level security;
alter table public.attempts enable row level security;

drop policy if exists "Owner can read owner account" on public.owner_accounts;
create policy "Owner can read owner account" on public.owner_accounts
for select to authenticated using (user_id = auth.uid());

drop policy if exists "Public can read published quizzes" on public.quizzes;
create policy "Public can read published quizzes" on public.quizzes
for select to anon, authenticated using (is_published = true or public.is_quiz_owner());

drop policy if exists "Owner manages quizzes" on public.quizzes;
create policy "Owner manages quizzes" on public.quizzes
for all to authenticated using (public.is_quiz_owner()) with check (public.is_quiz_owner());

drop policy if exists "Public can read questions for published quizzes" on public.questions;
create policy "Public can read questions for published quizzes" on public.questions
for select to anon, authenticated using (
  public.is_quiz_owner() or exists (
    select 1 from public.quizzes q where q.id = quiz_id and q.is_published = true
  )
);

drop policy if exists "Owner manages questions" on public.questions;
create policy "Owner manages questions" on public.questions
for all to authenticated using (public.is_quiz_owner()) with check (
  public.is_quiz_owner() and correct_option_index < jsonb_array_length(options)
);

drop policy if exists "Public can submit quiz attempts" on public.attempts;
create policy "Public can submit quiz attempts" on public.attempts
for insert to anon, authenticated with check (
  char_length(student_name) between 1 and 100 and
  total_questions > 0 and score >= 0 and score <= total_questions and
  accuracy between 0 and 100 and
  exists (select 1 from public.quizzes q where q.id = quiz_id and q.is_published = true)
);

drop policy if exists "Owner can view attempts" on public.attempts;
create policy "Owner can view attempts" on public.attempts
for select to authenticated using (public.is_quiz_owner());

-- IMPORTANT: Run after creating your owner account in Authentication > Users.
-- Replace the UUID with your owner's actual auth user UUID:
-- insert into public.owner_accounts (user_id) values ('OWNER_AUTH_USER_UUID_HERE');
