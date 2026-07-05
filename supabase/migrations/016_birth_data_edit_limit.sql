-- ============================================================
-- Migration 016: Limit how many times a user can edit their
-- birth data, and stop Birth Map / Astrocartography reports
-- from being reused for free once birth data changes.
--
-- profiles.birth_data_version starts at 0 and is incremented by
-- edit_birth_data() on every accepted edit. It does double duty:
--   - compared against the tier's lifetime cap (free: 2, pro: 5)
--   - tags which "version" of birth data produced a given
--     birth_maps / astrocartography_unlocks row, so switching
--     birth data requires paying Stardust again while old
--     reports remain stored (never deleted).
-- ============================================================

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS birth_data_version INTEGER NOT NULL DEFAULT 0;

-- 1. birth_maps: scope caching to the birth-data version that produced it.
ALTER TABLE public.birth_maps
  ADD COLUMN IF NOT EXISTS birth_data_version INTEGER NOT NULL DEFAULT 0;

ALTER TABLE public.birth_maps
  DROP CONSTRAINT IF EXISTS birth_maps_user_language_unique;

ALTER TABLE public.birth_maps
  ADD CONSTRAINT birth_maps_user_version_language_unique UNIQUE (user_id, birth_data_version, language);

-- 2. astrocartography_unlocks: real unlock tracking (previously inferred by
-- string-matching stardust_transactions.description), scoped per birth-data
-- version so editing birth data requires unlocking again.
CREATE TABLE IF NOT EXISTS public.astrocartography_unlocks (
  id                  UUID        PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  user_id             UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  birth_data_version  INTEGER     NOT NULL,
  unlocked_at         TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT astrocartography_unlocks_user_version_unique UNIQUE (user_id, birth_data_version)
);

ALTER TABLE public.astrocartography_unlocks ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename  = 'astrocartography_unlocks'
      AND policyname = 'Users can read own astrocartography unlocks'
  ) THEN
    CREATE POLICY "Users can read own astrocartography unlocks"
      ON public.astrocartography_unlocks FOR SELECT
      USING (auth.uid() = user_id);
  END IF;
END $$;

GRANT SELECT, INSERT ON public.astrocartography_unlocks TO authenticated;
GRANT SELECT, INSERT ON public.astrocartography_unlocks TO service_role;

-- 3. edit_birth_data: atomically enforce the lifetime edit cap and bump
-- birth_data_version. Free plan: 2 lifetime edits. Pro (any non-free tier): 5.
CREATE OR REPLACE FUNCTION public.edit_birth_data(
  p_user_id     UUID,
  p_birth_date  DATE,
  p_birth_time  TIME,
  p_birth_city  TEXT,
  p_birth_lat   DOUBLE PRECISION,
  p_birth_lng   DOUBLE PRECISION,
  p_sun_sign    zodiac_sign,
  p_moon_sign   zodiac_sign,
  p_rising_sign zodiac_sign,
  p_mc_sign     zodiac_sign
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_tier    TEXT;
  v_version INTEGER;
  v_limit   INTEGER;
BEGIN
  SELECT subscription_tier, birth_data_version
    INTO v_tier, v_version
    FROM public.profiles
   WHERE id = p_user_id
     FOR UPDATE;

  v_limit := CASE WHEN v_tier = 'free' THEN 2 ELSE 5 END;

  IF v_version >= v_limit THEN
    RETURN jsonb_build_object('success', false, 'remaining', 0, 'limit', v_limit);
  END IF;

  PERFORM set_config('app.allow_birth_edit', 'true', true);

  UPDATE public.profiles
     SET birth_date         = p_birth_date,
         birth_time         = p_birth_time,
         birth_city         = p_birth_city,
         birth_lat          = p_birth_lat,
         birth_lng          = p_birth_lng,
         sun_sign           = p_sun_sign,
         moon_sign          = p_moon_sign,
         rising_sign        = p_rising_sign,
         mc_sign            = p_mc_sign,
         birth_data_version = birth_data_version + 1,
         updated_at         = now()
   WHERE id = p_user_id;

  RETURN jsonb_build_object('success', true, 'remaining', v_limit - (v_version + 1), 'limit', v_limit);
END;
$$;

GRANT EXECUTE ON FUNCTION public.edit_birth_data(UUID, DATE, TIME, TEXT, DOUBLE PRECISION, DOUBLE PRECISION, zodiac_sign, zodiac_sign, zodiac_sign, zodiac_sign) TO authenticated;

-- edit_birth_data() sets a transaction-local flag before updating birth
-- fields; without it this trigger blocks changes to already-set birth data
-- so the limit can't be bypassed via a direct profiles UPDATE/upsert (which
-- the authenticated role otherwise has privilege to do, e.g. from the
-- ordinary "save profile" path). The FIRST time birth data is set — during
-- onboarding, when it's still NULL — is always allowed.
CREATE OR REPLACE FUNCTION public.protect_birth_data_edit()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.birth_date IS NOT NULL AND (
       NEW.birth_date IS DISTINCT FROM OLD.birth_date OR
       NEW.birth_time IS DISTINCT FROM OLD.birth_time OR
       NEW.birth_city IS DISTINCT FROM OLD.birth_city
     ) AND current_setting('app.allow_birth_edit', true) IS DISTINCT FROM 'true' THEN
    RAISE EXCEPTION 'Birth data can only be changed via edit_birth_data()';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_protect_birth_data_edit ON public.profiles;
CREATE TRIGGER trg_protect_birth_data_edit
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.protect_birth_data_edit();

-- 4. unlock_astrocartography: charge Stardust once per birth-data version.
-- Re-opening the screen (or calling this again for the same version) never
-- double-charges; an old version's unlock row is left in place as history.
CREATE OR REPLACE FUNCTION public.unlock_astrocartography(
  p_user_id UUID,
  p_amount  INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_version INTEGER;
  v_ok      BOOLEAN;
BEGIN
  SELECT birth_data_version INTO v_version
    FROM public.profiles
   WHERE id = p_user_id;

  IF EXISTS (
    SELECT 1 FROM public.astrocartography_unlocks
     WHERE user_id = p_user_id AND birth_data_version = v_version
  ) THEN
    RETURN jsonb_build_object('success', true, 'charged', false);
  END IF;

  SELECT public.spend_stardust(p_user_id, p_amount, 'Astrocartography Full Report') INTO v_ok;

  IF NOT v_ok THEN
    RETURN jsonb_build_object('success', false, 'reason', 'insufficient_stardust');
  END IF;

  INSERT INTO public.astrocartography_unlocks (user_id, birth_data_version)
  VALUES (p_user_id, v_version);

  RETURN jsonb_build_object('success', true, 'charged', true);
END;
$$;

GRANT EXECUTE ON FUNCTION public.unlock_astrocartography(UUID, INTEGER) TO authenticated;
