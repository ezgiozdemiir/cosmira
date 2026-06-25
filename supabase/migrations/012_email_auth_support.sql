-- ============================================================
-- Fix profiles table to support email sign-up.
-- The original schema required first_name, birth_date, birth_city at insert
-- time, but these are only collected during onboarding — not at sign-up.
-- ============================================================

ALTER TABLE public.profiles
  ALTER COLUMN first_name DROP NOT NULL,
  ALTER COLUMN birth_date DROP NOT NULL,
  ALTER COLUMN birth_city DROP NOT NULL;

-- ============================================================
-- Trigger: auto-create a minimal profile row for every new
-- auth user (Google, Apple, OR email/password).
-- The existing on_profile_created trigger then cascades to
-- create the wallet, streaks, notification prefs, and subscription.
-- ============================================================

CREATE OR REPLACE FUNCTION public.handle_auth_user_created()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, first_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(
      NULLIF(NEW.raw_user_meta_data->>'full_name',    ''),
      NULLIF(NEW.raw_user_meta_data->>'display_name', ''),
      NULLIF(NEW.raw_user_meta_data->>'name',         ''),
      split_part(NEW.email, '@', 1)   -- fallback: email prefix
    ),
    NULLIF(NEW.raw_user_meta_data->>'avatar_url', '')
  )
  ON CONFLICT (id) DO NOTHING;   -- idempotent if a row already exists
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Replace any existing trigger with the same name; harmless if absent.
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_auth_user_created();
