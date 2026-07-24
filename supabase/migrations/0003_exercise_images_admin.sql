-- Add image_url to exercises and admin role to profiles.
-- Restrict exercise catalog mutations to admin users only.

-- ─────────────────────────────────────────────────────────────────────────
-- 1. Add image_url column to exercises
-- ─────────────────────────────────────────────────────────────────────────

alter table public.exercises add column image_url text;

-- ─────────────────────────────────────────────────────────────────────────
-- 2. Add is_admin flag to profiles (default false)
-- ─────────────────────────────────────────────────────────────────────────

alter table public.profiles add column is_admin boolean not null default false;

-- ─────────────────────────────────────────────────────────────────────────
-- 3. Helper: check if the current user is an admin
-- ─────────────────────────────────────────────────────────────────────────

create function public.is_admin()
returns boolean
language sql stable security definer
as $$
  select coalesce(
    (select is_admin from public.profiles where id = auth.uid()),
    false
  );
$$;

-- ─────────────────────────────────────────────────────────────────────────
-- 4. Replace exercise mutation RLS policies — only admins can mutate
-- ─────────────────────────────────────────────────────────────────────────

-- Drop old user-scoped mutation policies
drop policy if exists "exercises_insert_own" on public.exercises;
drop policy if exists "exercises_update_own" on public.exercises;
drop policy if exists "exercises_delete_own" on public.exercises;

-- New admin-only mutation policies
create policy "exercises_insert_admin" on public.exercises
  for insert with check (public.is_admin());

create policy "exercises_update_admin" on public.exercises
  for update using (public.is_admin());

create policy "exercises_delete_admin" on public.exercises
  for delete using (public.is_admin());

-- SELECT stays the same: everyone sees global exercises (owner_id is null)
-- and their own custom exercises (though custom creation is now admin-only too).

-- ─────────────────────────────────────────────────────────────────────────
-- 5. Supabase Storage bucket for exercise images (public read)
-- ─────────────────────────────────────────────────────────────────────────

insert into storage.buckets (id, name, public)
values ('exercise-images', 'exercise-images', true)
on conflict (id) do nothing;

-- Anyone can read images (public bucket)
create policy "exercise_images_public_read" on storage.objects
  for select using (bucket_id = 'exercise-images');

-- Only admins can upload/update/delete images
create policy "exercise_images_admin_insert" on storage.objects
  for insert with check (bucket_id = 'exercise-images' and public.is_admin());

create policy "exercise_images_admin_update" on storage.objects
  for update using (bucket_id = 'exercise-images' and public.is_admin());

create policy "exercise_images_admin_delete" on storage.objects
  for delete using (bucket_id = 'exercise-images' and public.is_admin());
