-- ============================================================
-- Migration 024: fix duplicated / bilingual notification_log rows.
--
-- Root cause: notification_service.dart decided whether an event had
-- already fired with a plain "SELECT existing keys, then INSERT if
-- missing" — not atomic. When the client-side generator ran twice in quick
-- succession (e.g. two provider rebuilds racing during startup), both reads
-- could see the key as missing and both would insert, sometimes with
-- different `languageCode` values, producing the same event twice in two
-- languages. There was also no DB-level constraint to prevent this.
--
-- Fix: promote event_key out of the `data` JSONB blob into a first-class
-- column, backfill it, drop duplicate rows (keeping the earliest per
-- event), and add a uniqueness constraint so the client can now use
-- upsert(..., ignoreDuplicates: true) to make inserts idempotent even
-- under a race.
-- ============================================================

ALTER TABLE public.notification_log
  ADD COLUMN IF NOT EXISTS event_key TEXT;

UPDATE public.notification_log
SET event_key = data->>'event_key'
WHERE event_key IS NULL AND data ? 'event_key';

-- Drop duplicate (user_id, event_key) rows, keeping the earliest occurrence.
WITH ranked AS (
  SELECT id,
         row_number() OVER (
           PARTITION BY user_id, event_key
           ORDER BY created_at ASC, id ASC
         ) AS rn
  FROM public.notification_log
  WHERE event_key IS NOT NULL
)
DELETE FROM public.notification_log
WHERE id IN (SELECT id FROM ranked WHERE rn > 1);

-- A plain (non-partial) unique constraint: every row this app writes always
-- has a non-null event_key, and a partial index would need a matching WHERE
-- clause on every ON CONFLICT statement to be usable as an upsert arbiter,
-- which the Supabase client doesn't add. Rows with a NULL event_key (there
-- shouldn't be any) don't conflict with each other under a plain UNIQUE
-- constraint, so this is safe either way.
ALTER TABLE public.notification_log
  ADD CONSTRAINT notification_log_user_event_key_unique UNIQUE (user_id, event_key);
