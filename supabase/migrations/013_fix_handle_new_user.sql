-- ============================================================
-- Restore handle_new_user() to its correct implementation.
-- It was overwritten in the Supabase dashboard with a broken
-- version that references NEW.raw_user_meta_data, which does
-- not exist on the profiles table, causing every new sign-up
-- to fail with "Database error saving new user" (HTTP 500).
--
-- This function is triggered by on_profile_created (AFTER
-- INSERT ON public.profiles) and should create the stardust
-- wallet, streak record, notification prefs, and subscription
-- for the new user.
-- ============================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.stardust_wallets (user_id, balance)
  VALUES (NEW.id, 50)
  ON CONFLICT (user_id) DO NOTHING;

  INSERT INTO public.user_streaks (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;

  INSERT INTO public.notification_preferences (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;

  INSERT INTO public.subscriptions (user_id, tier, status)
  VALUES (NEW.id, 'free', 'active')
  ON CONFLICT DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
