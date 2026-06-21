-- Migration 009: Language support for compatibility_reports
ALTER TABLE public.compatibility_reports
  ADD COLUMN IF NOT EXISTS language text NOT NULL DEFAULT 'en';
