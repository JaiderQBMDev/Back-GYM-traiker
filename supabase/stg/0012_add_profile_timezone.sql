-- Migration 0012: Add IANA timezone to profiles
-- Run against the STAGING Supabase project.
--
-- The backend previously computed "today"/calendar-day boundaries (streaks,
-- dashboard, weekly volume) using the server's clock instead of the user's.
-- Storing each user's IANA timezone lets the backend/DB convert timestamps
-- to the user's local calendar day instead of the server's.

alter table public.profiles
  add column if not exists timezone text not null default 'UTC';
