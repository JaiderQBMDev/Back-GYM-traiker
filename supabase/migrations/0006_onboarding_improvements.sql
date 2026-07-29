-- Onboarding improvements: new enums, profile fields, body measurement changes

-- ─────────────────────────────────────────────────────────────────────────
-- NEW ENUMS
-- ─────────────────────────────────────────────────────────────────────────

create type fitness_goal as enum (
  'lose_fat', 'gain_muscle', 'improve_fitness',
  'increase_strength', 'stay_healthy', 'other'
);

create type experience_level as enum ('beginner', 'intermediate', 'advanced');

create type routine_preference as enum ('create_own', 'receive_recommended');

-- ─────────────────────────────────────────────────────────────────────────
-- PROFILES — new onboarding columns
-- ─────────────────────────────────────────────────────────────────────────

alter table public.profiles
  add column sex text check (sex in ('male', 'female')),
  add column birth_year smallint check (birth_year between 1920 and 2020),
  add column training_days_per_week smallint check (training_days_per_week between 1 and 7),
  add column fitness_goal fitness_goal,
  add column experience_level experience_level,
  add column routine_preference routine_preference,
  add column onboarding_completed boolean not null default false;

-- Existing users already have accounts — mark them as onboarded
update public.profiles set onboarding_completed = true;

-- ─────────────────────────────────────────────────────────────────────────
-- BODY_MEASUREMENTS — add new columns, drop old ones
-- ─────────────────────────────────────────────────────────────────────────

alter table public.body_measurements
  add column body_fat_pct numeric(4,1) check (body_fat_pct between 1 and 70),
  add column muscle_mass_kg numeric(5,2) check (muscle_mass_kg between 5 and 200),
  add column visceral_fat_level smallint check (visceral_fat_level between 1 and 20);

alter table public.body_measurements
  drop column chest_cm,
  drop column waist_cm,
  drop column bicep_cm,
  drop column thigh_cm;
