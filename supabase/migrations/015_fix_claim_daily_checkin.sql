-- ============================================================
-- Migration 015: Fix claim_daily_checkin — use p_type
-- (earn_stardust uses p_type, not p_source)
-- ============================================================
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

  IF v_last_date = CURRENT_DATE THEN
    RETURN FALSE;
  END IF;

  PERFORM public.earn_stardust(
    p_user_id     := p_user_id,
    p_amount      := 1,
    p_type        := 'reward',
    p_description := 'Daily check-in'
  );

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
