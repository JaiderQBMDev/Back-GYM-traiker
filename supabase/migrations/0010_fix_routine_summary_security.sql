-- Fix: all views were running as security definer (the Postgres default),
-- which bypasses RLS and lets any user see all data.
-- Recreate with security_invoker so RLS on the underlying tables is enforced.

-- routine_summary
drop view if exists public.routine_summary;

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

grant select on public.routine_summary to authenticated;

-- workout_session_stats
drop view if exists public.workout_session_stats;

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

grant select on public.workout_session_stats to authenticated;

-- personal_records
drop view if exists public.personal_records;

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

grant select on public.personal_records to authenticated;
