-- Migration 0014: Deduplicate global exercises that only differ by letter case
-- Run against the STAGING Supabase project.
--
-- Migration 0011 inserted new exercises with capitalized names (e.g. 'Press
-- Declinado') without noticing that near-identical rows already existed from
-- the original seed with different casing (e.g. 'Press de banca declinado').
-- The unique index on exercises(name) is case-sensitive, so both rows landed
-- in the catalog. This migration merges those case-only duplicates safely,
-- without breaking routines/workouts already in use:
--
--   For every group of global exercises (owner_id is null) whose name is
--   identical once case/whitespace is ignored (within the same
--   muscle_group):
--     1. Keep the OLDEST row (by created_at) as the canonical exercise.
--     2. Repoint routine_exercises.exercise_id from the duplicate(s) to the
--        canonical id.
--     3. Repoint workout_sets.exercise_id the same way, skipping any row
--        that would violate the (session_id, exercise_id, set_number)
--        unique constraint (i.e. a user already logged that exact set for
--        the canonical exercise in the same session) — those are left
--        untouched and reported via RAISE WARNING for manual review.
--     4. Delete the duplicate exercise row ONLY if nothing still
--        references it.
--
-- Safe to re-run: it only acts on groups that still have more than one row,
-- and previously-merged groups will simply have nothing left to do.

do $$
declare
  dup record;
  canonical_id uuid;
begin
  for dup in
    select lower(trim(name)) as norm_name, muscle_group
    from public.exercises
    where owner_id is null
    group by lower(trim(name)), muscle_group
    having count(*) > 1
  loop
    select id into canonical_id
    from public.exercises
    where owner_id is null
      and lower(trim(name)) = dup.norm_name
      and muscle_group = dup.muscle_group
    order by created_at asc, id asc
    limit 1;

    raise notice 'Merging duplicates of "%" (%) into canonical id %', dup.norm_name, dup.muscle_group, canonical_id;

    -- 1. Repoint routine_exercises to the canonical exercise
    update public.routine_exercises re
    set exercise_id = canonical_id
    where re.exercise_id in (
      select id from public.exercises
      where owner_id is null
        and lower(trim(name)) = dup.norm_name
        and muscle_group = dup.muscle_group
        and id <> canonical_id
    );

    -- 2. Repoint workout_sets, skipping rows that would collide on
    --    (session_id, exercise_id, set_number)
    update public.workout_sets ws
    set exercise_id = canonical_id
    where ws.exercise_id in (
      select id from public.exercises
      where owner_id is null
        and lower(trim(name)) = dup.norm_name
        and muscle_group = dup.muscle_group
        and id <> canonical_id
    )
    and not exists (
      select 1 from public.workout_sets ws2
      where ws2.session_id = ws.session_id
        and ws2.exercise_id = canonical_id
        and ws2.set_number = ws.set_number
    );

    -- 3. Delete duplicate rows that are no longer referenced anywhere
    delete from public.exercises e
    where e.owner_id is null
      and lower(trim(e.name)) = dup.norm_name
      and e.muscle_group = dup.muscle_group
      and e.id <> canonical_id
      and not exists (select 1 from public.routine_exercises re where re.exercise_id = e.id)
      and not exists (select 1 from public.workout_sets ws where ws.exercise_id = e.id);
  end loop;

  -- Report any duplicates that survived (could not be fully merged, usually
  -- because of a workout_sets set_number collision) so they can be handled
  -- by hand.
  for dup in
    select e.name, e.muscle_group, e.id
    from public.exercises e
    where e.owner_id is null
      and exists (
        select 1 from public.exercises e2
        where e2.owner_id is null
          and e2.id <> e.id
          and lower(trim(e2.name)) = lower(trim(e.name))
          and e2.muscle_group = e.muscle_group
      )
  loop
    raise warning 'Exercise "%" (id=%, %) still has an unmerged duplicate sibling — needs manual review', dup.name, dup.id, dup.muscle_group;
  end loop;
end $$;

-- ─────────────────────────────────────────────────────────────────────
-- Part B: explicit semantic duplicates (confirmed by hand, name text
-- differs beyond case so they can't be auto-detected). Add one row per
-- confirmed pair as (name to remove, canonical name to keep, muscle_group).
-- Uses the same merge/skip/delete logic as Part A.
-- ─────────────────────────────────────────────────────────────────────

do $$
declare
  pair record;
  dup_id uuid;
  canonical_id uuid;
begin
  for pair in
    select * from (values
      -- Pecho
      ('Press de Banca',        'Press de banca con barra',      'pecho'::muscle_group),
      ('Press Inclinado',       'Press de banca inclinado',      'pecho'::muscle_group),
      ('Press Declinado',       'Press de banca declinado',      'pecho'::muscle_group),
      ('Aperturas',             'Aperturas con mancuernas',      'pecho'::muscle_group),
      ('Fondos para Pecho',     'Fondos en paralelas',           'pecho'::muscle_group),

      -- Piernas
      ('Sentadilla',            'Sentadilla con barra',          'piernas'::muscle_group),
      ('Curl Femoral',          'Curl femoral acostado',         'piernas'::muscle_group),

      -- Hombros
      ('Press Militar',         'Press militar con barra',       'hombros'::muscle_group),
      ('Pájaros',                'Pájaros con mancuernas',        'hombros'::muscle_group),
      ('Press en Máquina de Hombros', 'Press en máquina (hombro)', 'hombros'::muscle_group),

      -- Tríceps
      ('Extensión Tríceps',      'Extensión de tríceps en polea', 'triceps'::muscle_group),
      ('Extensión Tríceps en Polea', 'Extensión de tríceps en polea', 'triceps'::muscle_group),
      ('Extensión Tríceps con Cuerda', 'Extensión de tríceps con cuerda', 'triceps'::muscle_group),

      -- Abdomen
      ('Rueda Abdominal',       'Ab wheel',                      'abdomen'::muscle_group),
      ('Plancha',                'Plancha frontal',               'abdomen'::muscle_group),

      -- Glúteos
      ('Abducción de Cadera',    'Abducción de cadera en máquina', 'gluteos'::muscle_group),

      -- Pantorrillas
      ('Elevación de Talones',   'Elevación de talones de pie',   'pantorrillas'::muscle_group),

      -- Cardio
      ('Correr en Cinta',       'Cinta de correr',               'cardio'::muscle_group),
      ('Remo en Máquina Cardio', 'Remo ergómetro',                'cardio'::muscle_group)
    ) as t(dup_name, canonical_name, muscle_group)
  loop
    select id into dup_id
    from public.exercises
    where owner_id is null and name = pair.dup_name and muscle_group = pair.muscle_group;

    select id into canonical_id
    from public.exercises
    where owner_id is null and name = pair.canonical_name and muscle_group = pair.muscle_group;

    if dup_id is null or canonical_id is null then
      raise warning 'Skipping pair "%" -> "%" (%): one or both rows not found', pair.dup_name, pair.canonical_name, pair.muscle_group;
      continue;
    end if;

    raise notice 'Merging "%" (id=%) into "%" (id=%)', pair.dup_name, dup_id, pair.canonical_name, canonical_id;

    update public.routine_exercises
    set exercise_id = canonical_id
    where exercise_id = dup_id;

    update public.workout_sets ws
    set exercise_id = canonical_id
    where ws.exercise_id = dup_id
      and not exists (
        select 1 from public.workout_sets ws2
        where ws2.session_id = ws.session_id
          and ws2.exercise_id = canonical_id
          and ws2.set_number = ws.set_number
      );

    delete from public.exercises e
    where e.id = dup_id
      and not exists (select 1 from public.routine_exercises re where re.exercise_id = e.id)
      and not exists (select 1 from public.workout_sets ws where ws.exercise_id = e.id);

    if exists (select 1 from public.exercises where id = dup_id) then
      raise warning 'Exercise "%" (id=%) still has workout_sets referencing it — could not fully merge, needs manual review', pair.dup_name, dup_id;
    end if;
  end loop;
end $$;
