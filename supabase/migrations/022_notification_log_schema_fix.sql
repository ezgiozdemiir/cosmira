-- Migration 022: fix notification_log schema drift.
--
-- notification_log was created (001_initial_schema.sql) with columns
-- category/sent_at/opened_at, but the app's NotificationService has always
-- written type/is_read instead and never set category — every insert has
-- been silently failing (caught by an empty try/catch), so the in-app
-- notification list has always been empty for every user.
--
-- Add the columns the app actually uses, and relax the now-unused
-- `category` NOT NULL constraint so inserts stop failing.

ALTER TABLE public.notification_log
  ADD COLUMN IF NOT EXISTS type TEXT,
  ADD COLUMN IF NOT EXISTS is_read BOOLEAN NOT NULL DEFAULT false;

ALTER TABLE public.notification_log
  ALTER COLUMN category DROP NOT NULL;
