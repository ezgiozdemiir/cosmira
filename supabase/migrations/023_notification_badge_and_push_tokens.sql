-- ============================================================
-- Migration 023: unread notification badge + push notification tokens.
--
-- 1. notification_log has always been insert-only from the client (see
--    migration 022) — there was no UPDATE grant, so nothing could ever mark
--    a row as read. The existing "Users own notif log" RLS policy already
--    covers UPDATE (FOR ALL), only the table-level GRANT was missing.
--
-- 2. device_tokens stores one row per installed app instance (FCM
--    registration token) so an edge function can look up a user's devices
--    and send them a push notification when a notification_log row is
--    created. Token is UNIQUE (not user_id-scoped) because the same device
--    can be re-registered to a different account after logout/login.
-- ============================================================

GRANT UPDATE ON public.notification_log TO authenticated;

CREATE TABLE public.device_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,
  platform TEXT NOT NULL CHECK (platform IN ('android', 'ios', 'web')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_device_tokens_user ON public.device_tokens(user_id);

ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users own device tokens" ON public.device_tokens
  FOR ALL USING (auth.uid() = user_id);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.device_tokens TO authenticated;

-- The send-push edge function reads (and prunes dead) tokens via the
-- service-role client, which bypasses RLS but still needs table grants
-- (see migration 020 for the same gotcha with loved_ones).
GRANT SELECT, DELETE ON public.device_tokens TO service_role;
