-- ============================================================
-- Migration 019: Real, computed Astrocartography lines.
--
-- Astrocartography previously showed identical static content to every
-- user (fixed planet dot positions, one hardcoded line type per planet).
-- This adds cache tables for genuinely computed AC/DC/MC/IC line paths per
-- planet, derived server-side from each person's actual birth date/time/
-- lat/lng (see the `calculate-astrocartography-lines` edge function).
--
-- Pure deterministic math (no AI cost) — these tables are purely a cache
-- to avoid recomputing on every screen open, written by the edge function
-- via the service role, same pattern as `birth_maps`/`loved_one_birth_maps`.
-- ============================================================

CREATE TABLE IF NOT EXISTS public.astrocartography_lines (
  id                 UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  user_id            UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  birth_data_version INTEGER NOT NULL,
  content            JSONB NOT NULL,
  engine_version     TEXT NOT NULL DEFAULT 'v1',
  created_at         TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT astrocartography_lines_user_version_unique UNIQUE (user_id, birth_data_version)
);

CREATE INDEX IF NOT EXISTS idx_astrocartography_lines_user ON public.astrocartography_lines(user_id);

ALTER TABLE public.astrocartography_lines ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'astrocartography_lines'
      AND policyname = 'Users can read own astrocartography lines'
  ) THEN
    CREATE POLICY "Users can read own astrocartography lines" ON public.astrocartography_lines
      FOR SELECT USING (auth.uid() = user_id);
  END IF;
END $$;

GRANT SELECT ON public.astrocartography_lines TO authenticated;
GRANT SELECT, INSERT ON public.astrocartography_lines TO service_role;

-- ------------------------------------------------------------
-- Computed lines for a Loved One — keyed by loved_one_id, no version
-- dimension needed since loved_ones rows are immutable.
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.loved_one_astrocartography_lines (
  id             UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  user_id        UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  loved_one_id   UUID NOT NULL REFERENCES public.loved_ones(id) ON DELETE CASCADE,
  content        JSONB NOT NULL,
  engine_version TEXT NOT NULL DEFAULT 'v1',
  created_at     TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT loved_one_astrocartography_lines_unique UNIQUE (loved_one_id)
);

ALTER TABLE public.loved_one_astrocartography_lines ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'loved_one_astrocartography_lines'
      AND policyname = 'Users can read own loved-one astrocartography lines'
  ) THEN
    CREATE POLICY "Users can read own loved-one astrocartography lines" ON public.loved_one_astrocartography_lines
      FOR SELECT USING (auth.uid() = user_id);
  END IF;
END $$;

GRANT SELECT ON public.loved_one_astrocartography_lines TO authenticated;
GRANT SELECT, INSERT ON public.loved_one_astrocartography_lines TO service_role;
