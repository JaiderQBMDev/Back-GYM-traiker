-- View used by the "Mis Rutinas" screen (2c): exercise count + last time
-- the routine was completed. Kept in the DB so the API layer never has to
-- hand-aggregate this in application code.

-- NOTE: Views don't have their own RLS policies. This view inherits row-level
-- security from its underlying tables (routines, routine_exercises,
-- workout_sessions), so each user can only see their own routines — no
-- explicit policy is needed here.
create view public.routine_summary as
select
  r.id as routine_id,
  r.user_id,
  r.name,
  r.is_favorite,
  r.position,
  count(distinct re.id) as exercise_count,
  max(s.started_at) filter (where s.status = 'completed') as last_completed_at
from public.routines r
left join public.routine_exercises re on re.routine_id = r.id
left join public.workout_sessions s on s.routine_id = r.id
group by r.id;
