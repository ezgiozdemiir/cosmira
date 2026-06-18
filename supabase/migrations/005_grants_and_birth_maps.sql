-- ============================================================
-- Migration 005: Create birth_maps table + fix missing GRANT
-- statements on all app tables.
--
-- Root cause: Supabase doesn't auto-grant SELECT/INSERT/etc to
-- the `authenticated` role when a table is created — RLS alone
-- isn't enough; you also need table-level privileges.
-- ============================================================

-- Birth Maps (one personalized cosmic report per user)
CREATE TABLE IF NOT EXISTS public.birth_maps (
  id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content     JSONB       NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT birth_maps_user_unique UNIQUE (user_id)
);

ALTER TABLE public.birth_maps ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename  = 'birth_maps'
      AND policyname = 'Users can read own birth map'
  ) THEN
    CREATE POLICY "Users can read own birth map"
      ON public.birth_maps FOR SELECT
      USING (auth.uid() = user_id);
  END IF;
END $$;

-- ============================================================
-- Grants — every table the authenticated role needs to touch.
-- RLS policies then narrow access to the correct rows.
-- ============================================================

GRANT SELECT, INSERT, UPDATE, DELETE ON public.stardust_wallets      TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.stardust_transactions  TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.birth_maps             TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.birth_maps             TO service_role;

GRANT SELECT, INSERT, UPDATE         ON public.profiles               TO authenticated;
GRANT SELECT, INSERT                 ON public.big_three_insights     TO authenticated;
GRANT SELECT, INSERT                 ON public.house_insights         TO authenticated;
GRANT SELECT                         ON public.daily_horoscopes       TO authenticated;

GRANT SELECT                         ON public.natal_charts           TO authenticated;
GRANT SELECT                         ON public.subscriptions          TO authenticated;
GRANT SELECT, INSERT, UPDATE         ON public.user_streaks           TO authenticated;
GRANT SELECT, INSERT                 ON public.breathwork_sessions    TO authenticated;
GRANT SELECT                         ON public.moon_phases            TO authenticated;
GRANT SELECT, INSERT                 ON public.notification_preferences TO authenticated;
GRANT SELECT, INSERT                 ON public.notification_log       TO authenticated;
GRANT SELECT, INSERT                 ON public.compatibility_reports  TO authenticated;
GRANT SELECT, INSERT, DELETE         ON public.compatibility_partners TO authenticated;
GRANT SELECT, INSERT                 ON public.ad_rewards             TO authenticated;
