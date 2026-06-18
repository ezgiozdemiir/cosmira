-- ============================================================
-- Adds the Midheaven angle to profiles, and a sign-combo-keyed
-- cache for free/premium Big Three insight content (personality
-- summary + premium daily/monthly/yearly predictions).
-- ============================================================

ALTER TABLE public.profiles
  ADD COLUMN mc_sign zodiac_sign;

CREATE TYPE insight_tier AS ENUM ('free', 'premium');
CREATE TYPE insight_period AS ENUM ('static', 'daily', 'monthly', 'yearly');

CREATE TABLE public.big_three_insights (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sun_sign zodiac_sign NOT NULL,
  moon_sign zodiac_sign NOT NULL,
  rising_sign zodiac_sign NOT NULL,
  tier insight_tier NOT NULL,
  period insight_period NOT NULL,
  period_key TEXT NOT NULL, -- 'static', or 'YYYY-MM-DD' / 'YYYY-MM' / 'YYYY'
  content JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE UNIQUE INDEX idx_big_three_insights_key
  ON public.big_three_insights(sun_sign, moon_sign, rising_sign, tier, period, period_key);

-- Shared across every user with the same Big Three combination, same
-- public-read principle as daily_horoscopes / moon_phases.
ALTER TABLE public.big_three_insights ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read big three insights" ON public.big_three_insights
  FOR SELECT USING (true);
