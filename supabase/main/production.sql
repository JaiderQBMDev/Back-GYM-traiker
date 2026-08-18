-- ═══════════════════════════════════════════════════════════════════════
-- GYM TRACKER — Production Schema (consolidated)
-- Run this script in Supabase SQL Editor on a fresh project.
-- It consolidates migrations 0001–0010 + seed data into a single file.
-- ═══════════════════════════════════════════════════════════════════════

begin;

-- ─────────────────────────────────────────────────────────────────────
-- EXTENSIONS
-- ─────────────────────────────────────────────────────────────────────

create extension if not exists "pgcrypto";

-- ─────────────────────────────────────────────────────────────────────
-- ENUMS
-- ─────────────────────────────────────────────────────────────────────

create type muscle_group as enum (
  'pecho', 'espalda', 'piernas', 'hombros', 'biceps', 'triceps',
  'abdomen', 'gluteos', 'pantorrillas', 'antebrazo', 'cardio', 'otro'
);

create type session_status as enum ('in_progress', 'completed', 'cancelled');

create type fitness_goal as enum (
  'lose_fat', 'gain_muscle', 'improve_fitness',
  'increase_strength', 'stay_healthy', 'other'
);

create type experience_level as enum ('beginner', 'intermediate', 'advanced');

create type routine_preference as enum ('create_own', 'receive_recommended');

-- ─────────────────────────────────────────────────────────────────────
-- TABLES
-- ─────────────────────────────────────────────────────────────────────

-- Profiles (1:1 with auth.users)
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  avatar_url text,
  height_cm numeric(5,2),
  weight_unit text not null default 'kg' check (weight_unit in ('kg', 'lb')),
  is_admin boolean not null default false,
  sex text check (sex in ('male', 'female')),
  birth_year smallint check (birth_year between 1920 and 2020),
  training_days_per_week smallint check (training_days_per_week between 1 and 7),
  fitness_goal fitness_goal,
  experience_level experience_level,
  routine_preference routine_preference,
  onboarding_completed boolean not null default false,
  timezone text not null default 'UTC',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Exercises (global catalog: owner_id NULL; custom: owner_id = user)
create table public.exercises (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references public.profiles(id) on delete cascade,
  name text not null,
  muscle_group muscle_group not null,
  equipment text,
  image_url text,
  notes text,
  created_at timestamptz not null default now()
);

create index exercises_owner_id_idx on public.exercises (owner_id);
create index exercises_muscle_group_idx on public.exercises (muscle_group);
create unique index exercises_global_name_uniq on public.exercises (name) where owner_id is null;
create unique index exercises_owner_name_uniq on public.exercises (owner_id, name) where owner_id is not null;

-- Routines
create table public.routines (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  is_favorite boolean not null default false,
  position int not null default 0,
  assigned_day smallint check (assigned_day between 0 and 6),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index routines_user_id_idx on public.routines (user_id);

-- Routine exercises (ordered list of exercises in a routine)
create table public.routine_exercises (
  id uuid primary key default gen_random_uuid(),
  routine_id uuid not null references public.routines(id) on delete cascade,
  exercise_id uuid not null references public.exercises(id) on delete restrict,
  order_index int not null,
  target_sets int not null default 3,
  target_reps_min int not null default 8,
  target_reps_max int not null default 12,
  rest_seconds int not null default 90,
  notes text,
  unique (routine_id, order_index)
);

create index routine_exercises_routine_id_idx on public.routine_exercises (routine_id);
create index routine_exercises_exercise_id_idx on public.routine_exercises (exercise_id);

-- Workout sessions
create table public.workout_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  routine_id uuid references public.routines(id) on delete set null,
  routine_name_snapshot text not null,
  status session_status not null default 'in_progress',
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  created_at timestamptz not null default now()
);

create index workout_sessions_user_id_idx on public.workout_sessions (user_id, started_at desc);
create index workout_sessions_routine_id_idx on public.workout_sessions (routine_id);

-- Workout sets
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

-- Body measurements
create table public.body_measurements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  recorded_on date not null default current_date,
  weight_kg numeric(5,2),
  body_fat_pct numeric(4,1) check (body_fat_pct between 1 and 70),
  muscle_mass_kg numeric(5,2) check (muscle_mass_kg between 5 and 200),
  visceral_fat_level smallint check (visceral_fat_level between 1 and 20),
  notes text,
  created_at timestamptz not null default now(),
  unique (user_id, recorded_on)
);

create index body_measurements_user_id_idx on public.body_measurements (user_id, recorded_on desc);

-- ─────────────────────────────────────────────────────────────────────
-- PRIVATE SCHEMA (not exposed by PostgREST → no /rest/v1/rpc access)
-- ─────────────────────────────────────────────────────────────────────

create schema if not exists private;
grant usage on schema private to authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- FUNCTIONS
-- ─────────────────────────────────────────────────────────────────────

-- Auto-create profile on auth signup (trigger-only, never called directly)
create function private.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (new.id, new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'avatar_url');
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

-- Auto-update updated_at timestamp (trigger-only)
create function private.set_updated_at()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at before update on public.profiles
  for each row execute function private.set_updated_at();
create trigger routines_set_updated_at before update on public.routines
  for each row execute function private.set_updated_at();

-- Check if current user is admin (used by RLS policies, not callable via API)
create function private.is_admin()
returns boolean
language sql stable security definer set search_path = ''
as $$
  select coalesce(
    (select is_admin from public.profiles where id = auth.uid()),
    false
  );
$$;

grant execute on function private.is_admin() to authenticated;

-- Daily streak calculation
create function public.get_current_streak(p_user_id uuid, p_timezone text default 'UTC')
returns int
language sql stable set search_path = ''
as $$
  with days as (
    select distinct (started_at at time zone p_timezone)::date as d
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
    (select len from streaks where end_d >= ((now() at time zone p_timezone)::date - 1) order by end_d desc limit 1),
    0
  );
$$;

-- Atomic routine creation with exercises (RPC)
create function public.create_routine_with_exercises(
  p_name text,
  p_is_favorite boolean default false,
  p_assigned_day smallint default null,
  p_exercises jsonb default '[]'::jsonb
)
returns uuid
language plpgsql
security invoker set search_path = ''
as $$
declare
  v_routine_id uuid;
  v_exercise jsonb;
begin
  insert into public.routines (user_id, name, is_favorite, assigned_day)
  values (auth.uid(), p_name, p_is_favorite, p_assigned_day)
  returning id into v_routine_id;

  for v_exercise in select * from jsonb_array_elements(p_exercises)
  loop
    insert into public.routine_exercises (
      routine_id, exercise_id, order_index,
      target_sets, target_reps_min, target_reps_max, rest_seconds
    ) values (
      v_routine_id,
      (v_exercise->>'exercise_id')::uuid,
      (v_exercise->>'order_index')::int,
      coalesce((v_exercise->>'target_sets')::int, 3),
      coalesce((v_exercise->>'target_reps_min')::int, 8),
      coalesce((v_exercise->>'target_reps_max')::int, 12),
      coalesce((v_exercise->>'rest_seconds')::int, 90)
    );
  end loop;

  return v_routine_id;
end;
$$;

-- ─────────────────────────────────────────────────────────────────────
-- VIEWS (all with security_invoker to enforce RLS)
-- ─────────────────────────────────────────────────────────────────────

-- Routine summary: exercise count + last completed date
create view public.routine_summary
with (security_invoker = true)
as
select
  r.id as routine_id,
  r.user_id,
  r.name,
  r.is_favorite,
  r.position,
  r.assigned_day,
  count(distinct re.id) as exercise_count,
  max(s.started_at) filter (where s.status = 'completed') as last_completed_at
from public.routines r
left join public.routine_exercises re on re.routine_id = r.id
left join public.workout_sessions s on s.routine_id = r.id
group by r.id;

-- Session stats: duration, volume, sets, PR flag
create view public.workout_session_stats
with (security_invoker = true)
as
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

-- Personal records: best set per user/exercise
create view public.personal_records
with (security_invoker = true)
as
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

-- ─────────────────────────────────────────────────────────────────────
-- ROW LEVEL SECURITY
-- ─────────────────────────────────────────────────────────────────────

alter table public.profiles enable row level security;
alter table public.exercises enable row level security;
alter table public.routines enable row level security;
alter table public.routine_exercises enable row level security;
alter table public.workout_sessions enable row level security;
alter table public.workout_sets enable row level security;
alter table public.body_measurements enable row level security;

-- Profiles
create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = id);
create policy "profiles_insert_own" on public.profiles
  for insert with check (auth.uid() = id);
create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id);

-- Exercises: everyone reads global + own; only admins mutate
create policy "exercises_select" on public.exercises
  for select using (owner_id is null or owner_id = auth.uid());
create policy "exercises_insert_admin" on public.exercises
  for insert with check (private.is_admin());
create policy "exercises_update_admin" on public.exercises
  for update using (private.is_admin());
create policy "exercises_delete_admin" on public.exercises
  for delete using (private.is_admin());

-- Routines: owner-scoped
create policy "routines_all_own" on public.routines
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Routine exercises: scoped through parent routine
create policy "routine_exercises_all_own" on public.routine_exercises
  for all using (
    exists (select 1 from public.routines r where r.id = routine_id and r.user_id = auth.uid())
  ) with check (
    exists (select 1 from public.routines r where r.id = routine_id and r.user_id = auth.uid())
  );

-- Workout sessions: owner-scoped
create policy "workout_sessions_all_own" on public.workout_sessions
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Workout sets: scoped through parent session
create policy "workout_sets_all_own" on public.workout_sets
  for all using (
    exists (select 1 from public.workout_sessions s where s.id = session_id and s.user_id = auth.uid())
  ) with check (
    exists (select 1 from public.workout_sessions s where s.id = session_id and s.user_id = auth.uid())
  );

-- Body measurements: owner-scoped
create policy "body_measurements_all_own" on public.body_measurements
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ─────────────────────────────────────────────────────────────────────
-- GRANTS
-- ─────────────────────────────────────────────────────────────────────

grant usage on schema public to anon, authenticated;

-- Tables
grant select, insert, update, delete on public.profiles to authenticated;
grant select, insert, update, delete on public.exercises to authenticated;
grant select, insert, update, delete on public.routines to authenticated;
grant select, insert, update, delete on public.routine_exercises to authenticated;
grant select, insert, update, delete on public.workout_sessions to authenticated;
grant select, insert, update, delete on public.workout_sets to authenticated;
grant select, insert, update, delete on public.body_measurements to authenticated;

-- Views
grant select on public.routine_summary to authenticated;
grant select on public.workout_session_stats to authenticated;
grant select on public.personal_records to authenticated;

-- Anon read-only for exercise catalog
grant select on public.exercises to anon;

-- Sequences
grant usage on all sequences in schema public to authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- STORAGE (exercise images bucket)
-- ─────────────────────────────────────────────────────────────────────

insert into storage.buckets (id, name, public)
values ('exercise-images', 'exercise-images', true)
on conflict (id) do nothing;

create policy "exercise_images_admin_read" on storage.objects
  for select using (bucket_id = 'exercise-images' and private.is_admin());

create policy "exercise_images_admin_insert" on storage.objects
  for insert with check (bucket_id = 'exercise-images' and private.is_admin());

create policy "exercise_images_admin_update" on storage.objects
  for update using (bucket_id = 'exercise-images' and private.is_admin());

create policy "exercise_images_admin_delete" on storage.objects
  for delete using (bucket_id = 'exercise-images' and private.is_admin());

-- ─────────────────────────────────────────────────────────────────────
-- SEED DATA: Global exercise catalog
-- ─────────────────────────────────────────────────────────────────────

INSERT INTO public.exercises (owner_id, name, muscle_group, equipment) VALUES

-- Pecho
(NULL, 'Press de banca con barra',       'pecho', 'Barra'),
(NULL, 'Press de banca inclinado',        'pecho', 'Barra'),
(NULL, 'Press de banca declinado',        'pecho', 'Barra'),
(NULL, 'Press con mancuernas',            'pecho', 'Mancuernas'),
(NULL, 'Press inclinado con mancuernas',  'pecho', 'Mancuernas'),
(NULL, 'Aperturas con mancuernas',        'pecho', 'Mancuernas'),
(NULL, 'Aperturas en polea',              'pecho', 'Polea'),
(NULL, 'Fondos en paralelas',             'pecho', 'Peso corporal'),
(NULL, 'Press en máquina',                'pecho', 'Máquina'),
(NULL, 'Flexiones de pecho',              'pecho', 'Peso corporal'),

-- Espalda
(NULL, 'Dominadas',                       'espalda', 'Peso corporal'),
(NULL, 'Jalón al pecho',                  'espalda', 'Polea'),
(NULL, 'Remo con barra',                  'espalda', 'Barra'),
(NULL, 'Remo con mancuerna',              'espalda', 'Mancuernas'),
(NULL, 'Remo en polea baja',              'espalda', 'Polea'),
(NULL, 'Remo en máquina',                 'espalda', 'Máquina'),
(NULL, 'Pullover con mancuerna',          'espalda', 'Mancuernas'),
(NULL, 'Jalón tras nuca',                 'espalda', 'Polea'),
(NULL, 'Peso muerto',                     'espalda', 'Barra'),
(NULL, 'Face pull',                       'espalda', 'Polea'),

-- Piernas
(NULL, 'Sentadilla con barra',            'piernas', 'Barra'),
(NULL, 'Prensa de piernas',               'piernas', 'Máquina'),
(NULL, 'Sentadilla búlgara',              'piernas', 'Mancuernas'),
(NULL, 'Extensión de cuádriceps',         'piernas', 'Máquina'),
(NULL, 'Curl femoral acostado',           'piernas', 'Máquina'),
(NULL, 'Curl femoral sentado',            'piernas', 'Máquina'),
(NULL, 'Sentadilla hack',                 'piernas', 'Máquina'),
(NULL, 'Zancadas con mancuernas',         'piernas', 'Mancuernas'),
(NULL, 'Peso muerto rumano',              'piernas', 'Barra'),
(NULL, 'Sentadilla goblet',               'piernas', 'Mancuernas'),

-- Hombros
(NULL, 'Press militar con barra',         'hombros', 'Barra'),
(NULL, 'Press con mancuernas (hombro)',   'hombros', 'Mancuernas'),
(NULL, 'Elevaciones laterales',           'hombros', 'Mancuernas'),
(NULL, 'Elevaciones frontales',           'hombros', 'Mancuernas'),
(NULL, 'Pájaros con mancuernas',          'hombros', 'Mancuernas'),
(NULL, 'Press Arnold',                    'hombros', 'Mancuernas'),
(NULL, 'Elevaciones laterales en polea',  'hombros', 'Polea'),
(NULL, 'Press en máquina (hombro)',       'hombros', 'Máquina'),

-- Bíceps
(NULL, 'Curl con barra',                  'biceps', 'Barra'),
(NULL, 'Curl con mancuernas',             'biceps', 'Mancuernas'),
(NULL, 'Curl martillo',                   'biceps', 'Mancuernas'),
(NULL, 'Curl en banco Scott',             'biceps', 'Barra'),
(NULL, 'Curl en polea',                   'biceps', 'Polea'),
(NULL, 'Curl concentrado',                'biceps', 'Mancuernas'),
(NULL, 'Curl con barra Z',               'biceps', 'Barra'),

-- Tríceps
(NULL, 'Extensión de tríceps en polea',   'triceps', 'Polea'),
(NULL, 'Press francés',                   'triceps', 'Barra'),
(NULL, 'Fondos en banco',                 'triceps', 'Peso corporal'),
(NULL, 'Extensión con mancuerna',         'triceps', 'Mancuernas'),
(NULL, 'Patada de tríceps',               'triceps', 'Mancuernas'),
(NULL, 'Press cerrado',                   'triceps', 'Barra'),
(NULL, 'Extensión de tríceps con cuerda', 'triceps', 'Polea'),

-- Abdomen
(NULL, 'Crunch abdominal',                'abdomen', 'Peso corporal'),
(NULL, 'Crunch en polea',                 'abdomen', 'Polea'),
(NULL, 'Plancha frontal',                 'abdomen', 'Peso corporal'),
(NULL, 'Plancha lateral',                 'abdomen', 'Peso corporal'),
(NULL, 'Elevación de piernas colgado',    'abdomen', 'Peso corporal'),
(NULL, 'Russian twist',                   'abdomen', 'Mancuernas'),
(NULL, 'Ab wheel',                        'abdomen', 'Rueda abdominal'),

-- Glúteos
(NULL, 'Hip thrust con barra',            'gluteos', 'Barra'),
(NULL, 'Patada de glúteo en polea',       'gluteos', 'Polea'),
(NULL, 'Puente de glúteos',               'gluteos', 'Peso corporal'),
(NULL, 'Abducción de cadera en máquina',  'gluteos', 'Máquina'),
(NULL, 'Sentadilla sumo',                 'gluteos', 'Mancuernas'),
(NULL, 'Step up con mancuernas',          'gluteos', 'Mancuernas'),

-- Pantorrillas
(NULL, 'Elevación de talones de pie',     'pantorrillas', 'Máquina'),
(NULL, 'Elevación de talones sentado',    'pantorrillas', 'Máquina'),
(NULL, 'Elevación de talones en prensa',  'pantorrillas', 'Máquina'),
(NULL, 'Elevación de talones con mancuerna', 'pantorrillas', 'Mancuernas'),

-- Cardio
(NULL, 'Cinta de correr',                 'cardio', 'Máquina'),
(NULL, 'Bicicleta estática',              'cardio', 'Máquina'),
(NULL, 'Elíptica',                        'cardio', 'Máquina'),
(NULL, 'Remo ergómetro',                  'cardio', 'Máquina'),
(NULL, 'Saltar la cuerda',                'cardio', 'Cuerda'),
(NULL, 'Escaladora',                      'cardio', 'Máquina'),
(NULL, 'Burpees',                         'cardio', 'Peso corporal')

ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────
-- REVOKE internal Supabase functions from being called via REST API
-- ─────────────────────────────────────────────────────────────────────

do $block$
begin
  if exists (
    select 1 from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'rls_auto_enable'
  ) then
    execute 'revoke execute on function public.rls_auto_enable() from public, anon, authenticated';
  end if;
end;
$block$;

commit;
