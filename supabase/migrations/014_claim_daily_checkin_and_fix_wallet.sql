-- ============================================================
-- Migration 014: Create claim_daily_checkin RPC and fix
-- initial stardust wallet balance from 50 → 0.
-- ============================================================

-- Fix new-user wallet: start with 0 stardust instead of 50.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.stardust_wallets (user_id, balance)
  VALUES (NEW.id, 0)
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

-- Daily check-in: awards 1 Stardust and updates the streak.
-- Returns TRUE if the reward was granted, FALSE if already claimed today.
CREATE OR REPLACE FUNCTION public.claim_daily_checkin(p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_last_date      DATE;
  v_current_streak INT;
  v_longest_streak INT;
BEGIN
  SELECT last_active_date, current_streak, longest_streak
    INTO v_last_date, v_current_streak, v_longest_streak
    FROM public.user_streaks
   WHERE user_id = p_user_id;

  -- Already checked in today.
  IF v_last_date = CURRENT_DATE THEN
    RETURN FALSE;
  END IF;

  -- Award 1 Stardust.
  PERFORM public.earn_stardust(
    p_user_id     := p_user_id,
    p_amount      := 1,
    p_source      := 'reward',
    p_description := 'Daily check-in'
  );

  -- Continue streak if yesterday, otherwise reset to 1.
  IF v_last_date = CURRENT_DATE - INTERVAL '1 day' THEN
    v_current_streak := COALESCE(v_current_streak, 0) + 1;
  ELSE
    v_current_streak := 1;
  END IF;

  v_longest_streak := GREATEST(COALESCE(v_longest_streak, 0), v_current_streak);

  UPDATE public.user_streaks
     SET last_active_date = CURRENT_DATE,
         current_streak   = v_current_streak,
         longest_streak   = v_longest_streak,
         total_sessions   = total_sessions + 1,
         updated_at       = NOW()
   WHERE user_id = p_user_id;

  RETURN TRUE;
END;
$$;

GRANT EXECUTE ON FUNCTION public.claim_daily_checkin(UUID) TO authenticated;
