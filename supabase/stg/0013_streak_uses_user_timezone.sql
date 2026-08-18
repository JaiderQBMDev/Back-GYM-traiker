-- Migration 0013: get_current_streak uses the user's local calendar day
-- Run against the STAGING Supabase project, after 0012_add_profile_timezone.sql.
--
-- Previously this function bucketed workout_sessions into calendar days
-- using date(started_at)/current_date, which resolve in the DB session's
-- timezone (effectively UTC), not the user's. A session logged late at
-- night in a UTC-negative timezone could land on the wrong day, breaking
-- streak continuity. p_timezone (an IANA zone, e.g. 'America/Bogota')
-- defaults to 'UTC' so existing callers keep working unchanged.

create or replace function public.get_current_streak(p_user_id uuid, p_timezone text default 'UTC')
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
