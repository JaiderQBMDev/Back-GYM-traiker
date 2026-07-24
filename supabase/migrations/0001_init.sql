-- Gym Tracker — initial schema
-- Derived from design "Gym Tracker.dc.html": login/register, dashboard (streak,
-- weekly volume), routines list & detail, active session w/ rest timer + set
-- logging, session history, exercise progress chart, body measurements.

create extension if not exists "pgcrypto";

-- ─────────────────────────────────────────────────────────────────────────
-- ENUMS
-- ─────────────────────────────────────────────────────────────────────────

create type muscle_group as enum (
  'pecho', 'espalda', 'piernas', 'hombros', 'biceps', 'triceps',
  'abdomen', 'gluteos', 'pantorrillas', 'cardio', 'otro'
);

create type session_status as enum ('in_progress', 'completed', 'cancelled');

-- ─────────────────────────────────────────────────────────────────────────
-- PROFILES  (1:1 with auth.users — screen 2a login/register, 2b avatar initial)
-- ─────────────────────────────────────────────────────────────────────────

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  avatar_url text,
  height_cm numeric(5,2),                    -- used to compute IMC on screen 2h
  weight_unit text not null default 'kg' check (weight_unit in ('kg', 'lb')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- auto-create a profile row whenever a new auth user signs up (2a)
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (new.id, new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'avatar_url');
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ─────────────────────────────────────────────────────────────────────────
-- EXERCISES  (catalog — global rows have owner_id null, users may add their own)
-- ─────────────────────────────────────────────────────────────────────────

create table public.exercises (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references public.profiles(id) on delete cascade,
  name text not null,
  muscle_group muscle_group not null,
  equipment text,
  notes text,
  created_at timestamptz not null default now()
);

create index exercises_owner_id_idx on public.exercises (owner_id);
create index exercises_muscle_group_idx on public.exercises (muscle_group);

-- NULLs are distinct in a plain unique constraint, so global rows (owner_id
-- is null) need their own partial index to dedupe by name.
create unique index exercises_global_name_uniq on public.exercises (name) where owner_id is null;
create unique index exercises_owner_name_uniq on public.exercises (owner_id, name) where owner_id is not null;

-- ─────────────────────────────────────────────────────────────────────────
-- ROUTINES  (screen 2c "Mis Rutinas" — favorite, exercise count, last performed)
-- ─────────────────────────────────────────────────────────────────────────

create table public.routines (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  is_favorite boolean not null default false,
  position int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index routines_user_id_idx on public.routines (user_id);

-- ─────────────────────────────────────────────────────────────────────────
-- ROUTINE_EXERCISES  (screen 2d detail — ordered list, target sets/reps, rest)
-- ─────────────────────────────────────────────────────────────────────────

create table public.routine_exercises (
  id uuid primary key default gen_random_uuid(),
  routine_id uuid not null references public.routines(id) on delete cascade,
  exercise_id uuid not null references public.exercises(id) on delete restrict,
  order_index int not null,
  target_sets int not null default 3,
  target_reps_min int not null default 8,
  target_reps_max int not null default 12,
  rest_seconds int not null default 90,        -- screen 2e rest timer default
  notes text,
  unique (routine_id, order_index)
);

create index routine_exercises_routine_id_idx on public.routine_exercises (routine_id);
create index routine_exercises_exercise_id_idx on public.routine_exercises (exercise_id);

-- ─────────────────────────────────────────────────────────────────────────
-- WORKOUT_SESSIONS  (screen 2e active session, 2b/2f completed session cards)
-- ─────────────────────────────────────────────────────────────────────────

create table public.workout_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  routine_id uuid references public.routines(id) on delete set null,
  routine_name_snapshot text not null,          -- survives routine rename/delete
  status session_status not null default 'in_progress',
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  created_at timestamptz not null default now()
);

create index workout_sessions_user_id_idx on public.workout_sessions (user_id, started_at desc);
create index workout_sessions_routine_id_idx on public.workout_sessions (routine_id);

-- ─────────────────────────────────────────────────────────────────────────
-- WORKOUT_SETS  (screen 2e series mini-table: SERIE / REPS / KG / ✓)
-- ─────────────────────────────────────────────────────────────────────────

create table public.workout_sets (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.workout_sessions(id) on delete cascade,
  routine_exercise_id uuid references public.routine_exercises(id) on delete set null,
  exercise_id uuid not null references public.exercises(id) on delete restrict,
  set_number int not null,
  reps int,
  weight_kg numeric(6,2),
  is_completed boolean not null default false,
  completed_at timestamptz,
  is_personal_record boolean not null default false,
  created_at timestamptz not null default now(),
  unique (session_id, exercise_id, set_number)
);

create index workout_sets_session_id_idx on public.workout_sets (session_id);
create index workout_sets_exercise_id_idx on public.workout_sets (exercise_id);

-- ─────────────────────────────────────────────────────────────────────────
-- BODY_MEASUREMENTS  (screen 2h "Cuerpo" — weight + chest/waist/bicep/thigh)
-- ─────────────────────────────────────────────────────────────────────────

create table public.body_measurements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  recorded_on date not null default current_date,
  weight_kg numeric(5,2),
  chest_cm numeric(5,2),
  waist_cm numeric(5,2),
  bicep_cm numeric(5,2),
  thigh_cm numeric(5,2),
  notes text,
  created_at timestamptz not null default now(),
  unique (user_id, recorded_on)
);

create index body_measurements_user_id_idx on public.body_measurements (user_id, recorded_on desc);

-- ─────────────────────────────────────────────────────────────────────────
-- updated_at helper trigger
-- ─────────────────────────────────────────────────────────────────────────

create function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at before update on public.profiles
  for each row execute function public.set_updated_at();
create trigger routines_set_updated_at before update on public.routines
  for each row execute function public.set_updated_at();

-- ─────────────────────────────────────────────────────────────────────────
-- VIEWS  — derived stats the UI reads directly (dashboard, progress, history)
-- ─────────────────────────────────────────────────────────────────────────

-- per-session aggregate: duration, total volume, total sets (2b/2f cards)
-- NOTE: Views don't have their own RLS policies. This view inherits row-level
-- security from its underlying tables (workout_sessions, workout_sets), so
-- each user can only see rows they own — no explicit policy is needed here.
create view public.workout_session_stats as
select
  s.id as session_id,
  s.user_id,
  s.routine_id,
  s.routine_name_snapshot,
  s.status,
  s.started_at,
  s.ended_at,
  extract(epoch from (s.ended_at - s.started_at))::int / 60 as duration_minutes,
  coalesce(sum(ws.weight_kg * ws.reps) filter (where ws.is_completed), 0) as total_volume_kg,
  count(ws.id) filter (where ws.is_completed) as total_sets,
  bool_or(ws.is_personal_record) as has_pr
from public.workout_sessions s
left join public.workout_sets ws on ws.session_id = s.id
group by s.id;

-- best set ever per user/exercise (screen 2g "Récord personal")
-- NOTE: Views don't have their own RLS policies. This view inherits row-level
-- security from its underlying tables (workout_sets, workout_sessions), so
-- each user can only see their own records — no explicit policy is needed here.
create view public.personal_records as
select distinct on (s.user_id, ws.exercise_id)
  s.user_id,
  ws.exercise_id,
  ws.weight_kg,
  ws.reps,
  ws.completed_at
from public.workout_sets ws
join public.workout_sessions s on s.id = ws.session_id
where ws.is_completed and ws.weight_kg is not null
order by s.user_id, ws.exercise_id, ws.weight_kg desc, ws.completed_at asc;

-- current daily streak of completed sessions (dashboard "Racha 🔥")
create function public.get_current_streak(p_user_id uuid)
returns int
language sql stable
as $$
  with days as (
    select distinct date(started_at) as d
    from public.workout_sessions
    where user_id = p_user_id and status = 'completed'
  ),
  numbered as (
    select d, d - (row_number() over (order by d))::int as grp
    from days
  ),
  streaks as (
    select min(d) as start_d, max(d) as end_d, count(*) as len
    from numbered
    group by grp
  )
  select coalesce(
    (select len from streaks where end_d >= current_date - 1 order by end_d desc limit 1),
    0
  );
$$;

-- ─────────────────────────────────────────────────────────────────────────
-- ROW LEVEL SECURITY
-- ─────────────────────────────────────────────────────────────────────────

alter table public.profiles enable row level security;
alter table public.exercises enable row level security;
alter table public.routines enable row level security;
alter table public.routine_exercises enable row level security;
alter table public.workout_sessions enable row level security;
alter table public.workout_sets enable row level security;
alter table public.body_measurements enable row level security;

-- profiles: user can read/update only their own row
create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = id);
create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id);

-- exercises: everyone can read global (owner_id is null) + their own; users
-- can only insert/update/delete their own custom exercises
create policy "exercises_select" on public.exercises
  for select using (owner_id is null or owner_id = auth.uid());
create policy "exercises_insert_own" on public.exercises
  for insert with check (owner_id = auth.uid());
create policy "exercises_update_own" on public.exercises
  for update using (owner_id = auth.uid());
create policy "exercises_delete_own" on public.exercises
  for delete using (owner_id = auth.uid());

-- routines: fully owner-scoped
create policy "routines_all_own" on public.routines
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- routine_exercises: scoped through parent routine ownership
create policy "routine_exercises_all_own" on public.routine_exercises
  for all using (
    exists (select 1 from public.routines r where r.id = routine_id and r.user_id = auth.uid())
  ) with check (
    exists (select 1 from public.routines r where r.id = routine_id and r.user_id = auth.uid())
  );

-- workout_sessions: owner-scoped
create policy "workout_sessions_all_own" on public.workout_sessions
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- workout_sets: scoped through parent session ownership
create policy "workout_sets_all_own" on public.workout_sets
  for all using (
    exists (select 1 from public.workout_sessions s where s.id = session_id and s.user_id = auth.uid())
  ) with check (
    exists (select 1 from public.workout_sessions s where s.id = session_id and s.user_id = auth.uid())
  );

-- body_measurements: owner-scoped
create policy "body_measurements_all_own" on public.body_measurements
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
