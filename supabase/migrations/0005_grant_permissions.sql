-- Grant table-level permissions to authenticated and anon roles.
-- Supabase requires explicit GRANTs even when RLS policies exist —
-- RLS controls which rows, GRANTs control whether the role can
-- access the table at all.

grant usage on schema public to anon, authenticated;

grant select, insert, update, delete on public.profiles to authenticated;
grant select, insert, update, delete on public.exercises to authenticated;
grant select, insert, update, delete on public.routines to authenticated;
grant select, insert, update, delete on public.routine_exercises to authenticated;
grant select, insert, update, delete on public.workout_sessions to authenticated;
grant select, insert, update, delete on public.workout_sets to authenticated;
grant select, insert, update, delete on public.body_measurements to authenticated;

-- Views
grant select on public.workout_session_stats to authenticated;
grant select on public.personal_records to authenticated;
grant select on public.routine_summary to authenticated;

-- Read-only access for exercises (anon can browse catalog)
grant select on public.exercises to anon;

-- Allow INSERT policy on profiles for auto-creation
grant select, insert, update on public.profiles to authenticated;

-- Sequences (needed for serial columns if any, and gen_random_uuid)
grant usage on all sequences in schema public to authenticated;
