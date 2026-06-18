-- ============================================================
-- Adds a "point" dimension to daily_horoscopes so the same sign
-- can have separate Sun / Moon / Rising interpretations per day.
-- ============================================================

CREATE TYPE horoscope_point AS ENUM ('sun', 'moon', 'rising');

ALTER TABLE public.daily_horoscopes
  ADD COLUMN point horoscope_point NOT NULL DEFAULT 'sun';

DROP INDEX IF EXISTS idx_daily_horoscope_sign_date;

CREATE UNIQUE INDEX idx_daily_horoscope_sign_point_date
  ON public.daily_horoscopes(sign, point, date);
