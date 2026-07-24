-- Allow users to insert their own profile row (covers cases where the
-- on_auth_user_created trigger didn't fire or wasn't applied).
create policy "profiles_insert_own" on public.profiles
  for insert with check (auth.uid() = id);
