-- ============================================================
-- Migration 017: Snapshot the birth city used at each
-- Astrocartography unlock, so a history list can show what
-- birth data a past unlock corresponds to (Astrocartography's
-- content is mostly static text, so there's no per-version
-- generated content to store the way birth_maps does — the
-- birth city snapshot is the only thing that meaningfully
-- differs between versions).
-- ============================================================

ALTER TABLE public.astrocartography_unlocks
  ADD COLUMN IF NOT EXISTS birth_city TEXT;

DROP FUNCTION IF EXISTS public.unlock_astrocartography(UUID, INTEGER);

CREATE OR REPLACE FUNCTION public.unlock_astrocartography(
  p_user_id    UUID,
  p_amount     INTEGER,
  p_birth_city TEXT DEFAULT NULL
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

  INSERT INTO public.astrocartography_unlocks (user_id, birth_data_version, birth_city)
  VALUES (p_user_id, v_version, p_birth_city);

  RETURN jsonb_build_object('success', true, 'charged', true);
END;
$$;

GRANT EXECUTE ON FUNCTION public.unlock_astrocartography(UUID, INTEGER, TEXT) TO authenticated;
