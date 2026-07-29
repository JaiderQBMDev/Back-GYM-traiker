-- Add assigned_day to routines (0=Monday, 6=Sunday, NULL=any day)
alter table public.routines
  add column assigned_day smallint check (assigned_day between 0 and 6);

-- Recreate routine_summary to include assigned_day
drop view if exists public.routine_summary;

create view public.routine_summary as
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

grant select on public.routine_summary to authenticated;
