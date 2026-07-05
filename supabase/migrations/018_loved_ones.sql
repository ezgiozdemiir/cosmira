-- ============================================================
-- Migration 018: "Loved Ones" reports — lets a user generate a
-- Birth Map / unlock Astrocartography for someone else's birth
-- data (a gift report), independent of the existing Compatibility
-- partners feature (that one only needs an approximate sun sign
-- for a fun score; this one needs a full accurate chart).
--
-- loved_ones rows are immutable once created — no UPDATE policy
-- exists at all. If a user mis-enters someone's data they delete
-- and re-add, which sidesteps needing a birth_data_version-style
-- edit cap the way profiles.birth_date does.
-- ============================================================

CREATE TABLE IF NOT EXISTS public.loved_ones (
  id          UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  birth_date  DATE NOT NULL,
  birth_time  TIME NOT NULL,
  birth_city  TEXT NOT NULL,
  birth_lat   DOUBLE PRECISION,
  birth_lng   DOUBLE PRECISION,
  sun_sign    zodiac_sign NOT NULL,
  moon_sign   zodiac_sign NOT NULL,
  rising_sign zodiac_sign NOT NULL,
  mc_sign     zodiac_sign,
  created_at  TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_loved_ones_user ON public.loved_ones(user_id);

ALTER TABLE public.loved_ones ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'loved_ones'
      AND policyname = 'Users can view own loved ones'
  ) THEN
    CREATE POLICY "Users can view own loved ones" ON public.loved_ones
      FOR SELECT USING (auth.uid() = user_id);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'loved_ones'
      AND policyname = 'Users can add own loved ones'
  ) THEN
    CREATE POLICY "Users can add own loved ones" ON public.loved_ones
      FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'loved_ones'
      AND policyname = 'Users can delete own loved ones'
  ) THEN
    CREATE POLICY "Users can delete own loved ones" ON public.loved_ones
      FOR DELETE USING (auth.uid() = user_id);
  END IF;
END $$;

-- Deliberately no UPDATE policy — birth data is immutable once saved.

GRANT SELECT, INSERT, DELETE ON public.loved_ones TO authenticated;

-- ------------------------------------------------------------
-- Birth Map reports generated for a loved one. Mirrors
-- birth_maps, but keyed by loved_one_id instead of
-- (user_id, birth_data_version) since loved_ones rows never change.
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.loved_one_birth_maps (
  id           UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  user_id      UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  loved_one_id UUID NOT NULL REFERENCES public.loved_ones(id) ON DELETE CASCADE,
  content      JSONB NOT NULL,
  language     TEXT NOT NULL DEFAULT 'en',
  created_at   TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT loved_one_birth_maps_unique UNIQUE (loved_one_id, language)
);

CREATE INDEX IF NOT EXISTS idx_loved_one_birth_maps_user ON public.loved_one_birth_maps(user_id);

ALTER TABLE public.loved_one_birth_maps ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'loved_one_birth_maps'
      AND policyname = 'Users can read own loved-one birth maps'
  ) THEN
    CREATE POLICY "Users can read own loved-one birth maps" ON public.loved_one_birth_maps
      FOR SELECT USING (auth.uid() = user_id);
  END IF;
END $$;

GRANT SELECT, INSERT ON public.loved_one_birth_maps TO authenticated;
GRANT SELECT, INSERT ON public.loved_one_birth_maps TO service_role;

-- ------------------------------------------------------------
-- Astrocartography unlocks for a loved one. Mirrors
-- astrocartography_unlocks, but keyed by loved_one_id — no version
-- dimension needed since loved_ones rows are immutable.
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.loved_one_astrocartography_unlocks (
  id           UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  user_id      UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  loved_one_id UUID NOT NULL REFERENCES public.loved_ones(id) ON DELETE CASCADE,
  unlocked_at  TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT loved_one_astro_unlocks_unique UNIQUE (loved_one_id)
);

ALTER TABLE public.loved_one_astrocartography_unlocks ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'loved_one_astrocartography_unlocks'
      AND policyname = 'Users can read own loved-one astro unlocks'
  ) THEN
    CREATE POLICY "Users can read own loved-one astro unlocks" ON public.loved_one_astrocartography_unlocks
      FOR SELECT USING (auth.uid() = user_id);
  END IF;
END $$;

GRANT SELECT, INSERT ON public.loved_one_astrocartography_unlocks TO authenticated;
GRANT SELECT, INSERT ON public.loved_one_astrocartography_unlocks TO service_role;

-- ------------------------------------------------------------
-- unlock_astrocartography_for_loved_one: mirrors
-- unlock_astrocartography (see 016/017) but keyed by loved_one_id
-- instead of birth_data_version, with an explicit ownership check
-- since p_loved_one_id is client-supplied.
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.unlock_astrocartography_for_loved_one(
  p_user_id      UUID,
  p_loved_one_id UUID,
  p_amount       INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_owned BOOLEAN;
  v_ok    BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM public.loved_ones
     WHERE id = p_loved_one_id AND user_id = p_user_id
  ) INTO v_owned;

  IF NOT v_owned THEN
    RETURN jsonb_build_object('success', false, 'reason', 'not_found');
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.loved_one_astrocartography_unlocks
     WHERE loved_one_id = p_loved_one_id
  ) THEN
    RETURN jsonb_build_object('success', true, 'charged', false);
  END IF;

  SELECT public.spend_stardust(p_user_id, p_amount, 'Astrocartography Full Report (Loved One)') INTO v_ok;

  IF NOT v_ok THEN
    RETURN jsonb_build_object('success', false, 'reason', 'insufficient_stardust');
  END IF;

  INSERT INTO public.loved_one_astrocartography_unlocks (user_id, loved_one_id)
  VALUES (p_user_id, p_loved_one_id);

  RETURN jsonb_build_object('success', true, 'charged', true);
END;
$$;

GRANT EXECUTE ON FUNCTION public.unlock_astrocartography_for_loved_one(UUID, UUID, INTEGER) TO authenticated;
