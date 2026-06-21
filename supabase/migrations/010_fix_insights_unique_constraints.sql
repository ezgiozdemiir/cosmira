-- Migration 010: Fix unique indexes on big_three_insights and house_insights
-- to include the language column so per-language records can coexist.
--
-- Before this migration, inserting a Turkish record failed with a unique
-- constraint violation because the old indexes didn't include language,
-- causing the edge functions to error and return no data to the app.

-- big_three_insights: drop language-blind index, add language-aware one
DROP INDEX IF EXISTS public.idx_big_three_insights_key;
CREATE UNIQUE INDEX IF NOT EXISTS idx_big_three_insights_lang_key
  ON public.big_three_insights(sun_sign, moon_sign, rising_sign, tier, period, period_key, language);

-- house_insights: drop any existing unique constraint on rising_sign alone,
-- then add one that includes language
ALTER TABLE public.house_insights
  DROP CONSTRAINT IF EXISTS house_insights_rising_sign_key;
DROP INDEX IF EXISTS idx_house_insights_rising_sign;
CREATE UNIQUE INDEX IF NOT EXISTS idx_house_insights_rising_lang
  ON public.house_insights(rising_sign, language);
