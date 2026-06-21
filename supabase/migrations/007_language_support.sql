-- ============================================================
-- Migration 007: Language support for birth_maps and daily_horoscopes
-- Allows one birth map per (user_id, language) and one horoscope
-- per (sign, point, date, language).
-- ============================================================

-- 1. birth_maps: add language column, swap unique constraint
ALTER TABLE public.birth_maps
  ADD COLUMN IF NOT EXISTS language text NOT NULL DEFAULT 'en';

ALTER TABLE public.birth_maps
  DROP CONSTRAINT IF EXISTS birth_maps_user_unique;

ALTER TABLE public.birth_maps
  ADD CONSTRAINT birth_maps_user_language_unique UNIQUE (user_id, language);

-- 2. daily_horoscopes: add language column, swap unique index
ALTER TABLE public.daily_horoscopes
  ADD COLUMN IF NOT EXISTS language text NOT NULL DEFAULT 'en';

DROP INDEX IF EXISTS idx_daily_horoscope_sign_point_date;

CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_horoscope_sign_point_date_lang
  ON public.daily_horoscopes(sign, point, date, language);
