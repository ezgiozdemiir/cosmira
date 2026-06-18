-- ============================================================
-- Birth Maps: One personalized cosmic report per user.
-- Purchased permanently with 50 Stardust — generated once,
-- stored forever, readable anytime.
-- ============================================================

CREATE TABLE public.birth_maps (
  id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content     JSONB       NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT birth_maps_user_unique UNIQUE (user_id)
);

ALTER TABLE public.birth_maps ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own birth map"
  ON public.birth_maps FOR SELECT
  USING (auth.uid() = user_id);
