-- Add missing columns to compatibility_partners
ALTER TABLE public.compatibility_partners
  ADD COLUMN IF NOT EXISTS relationship TEXT NOT NULL DEFAULT 'romantic',
  ADD COLUMN IF NOT EXISTS avatar_url   TEXT;
