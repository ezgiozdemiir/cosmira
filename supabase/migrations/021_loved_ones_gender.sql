-- ============================================================
-- Migration 021: Add gender to loved_ones, matching the field already
-- collected for the user's own profile in Edit Profile / onboarding.
-- ============================================================

ALTER TABLE public.loved_ones
  ADD COLUMN IF NOT EXISTS gender TEXT;
