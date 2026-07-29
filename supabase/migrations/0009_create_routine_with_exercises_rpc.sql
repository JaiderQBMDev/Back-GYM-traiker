create or replace function public.create_routine_with_exercises(
  p_name text,
  p_is_favorite boolean default false,
  p_assigned_day smallint default null,
  p_exercises jsonb default '[]'::jsonb
)
returns uuid
language plpgsql
security invoker
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
