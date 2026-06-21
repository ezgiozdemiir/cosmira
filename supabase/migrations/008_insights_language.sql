-- ============================================================
-- Migration 008: Language support for big_three_insights and house_insights
-- ============================================================

-- 1. big_three_insights: add language, include it in unique cache key
ALTER TABLE public.big_three_insights
  ADD COLUMN IF NOT EXISTS language text NOT NULL DEFAULT 'en';

-- 2. house_insights: add language, swap unique constraint
ALTER TABLE public.house_insights
  ADD COLUMN IF NOT EXISTS language text NOT NULL DEFAULT 'en';
