-- ============================================================
-- COSMIRA DATABASE SCHEMA
-- PostgreSQL via Supabase
-- ============================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE gender_type AS ENUM ('female', 'male', 'non_binary', 'prefer_not_to_say');
CREATE TYPE relationship_status AS ENUM ('single', 'in_relationship', 'married', 'complicated', 'prefer_not_to_say');
CREATE TYPE subscription_tier AS ENUM ('free', 'premium_monthly', 'premium_yearly', 'lifetime');
CREATE TYPE subscription_status AS ENUM ('active', 'expired', 'cancelled', 'trial', 'grace_period');
CREATE TYPE report_type AS ENUM (
  'natal_chart', 'daily_horoscope', 'synastry', 'composite',
  'transit', 'yearly_destiny', 'astrocartography', 'moon_ritual',
  'energy_insight', 'compatibility_deep', 'breathwork_guide'
);
CREATE TYPE ai_provider AS ENUM ('gemini', 'openai');
CREATE TYPE transaction_type AS ENUM ('purchase', 'reward', 'spend', 'refund', 'bonus');
CREATE TYPE zodiac_sign AS ENUM (
  'aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
  'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces'
);
CREATE TYPE element_type AS ENUM ('fire', 'earth', 'air', 'water');
CREATE TYPE breathwork_type AS ENUM (
  'box_breathing', 'sleep_breathing', 'anxiety_relief',
  'moon_breathing', 'feminine_energy'
);
CREATE TYPE notification_category AS ENUM (
  'daily_horoscope', 'moon_phase', 'transit_alert',
  'compatibility', 'ritual_reminder', 'energy_shift',
  'streak', 'promotional'
);
CREATE TYPE intent_type AS ENUM (
  'love', 'healing', 'inner_peace', 'feminine_energy',
  'self_discovery', 'career'
);

-- ============================================================
-- USERS
-- ============================================================

CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  first_name TEXT NOT NULL,
  last_name TEXT,
  email TEXT,
  avatar_url TEXT,
  birth_date DATE NOT NULL,
  birth_time TIME,
  birth_city TEXT NOT NULL,
  birth_lat DOUBLE PRECISION,
  birth_lng DOUBLE PRECISION,
  current_city TEXT,
  gender gender_type DEFAULT 'prefer_not_to_say',
  relationship_status relationship_status DEFAULT 'prefer_not_to_say',
  language TEXT DEFAULT 'en',
  timezone TEXT DEFAULT 'UTC',
  notification_enabled BOOLEAN DEFAULT true,
  sun_sign zodiac_sign,
  moon_sign zodiac_sign,
  rising_sign zodiac_sign,
  dominant_element element_type,
  intents intent_type[] DEFAULT '{}',
  onboarding_completed BOOLEAN DEFAULT false,
  is_guest BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- SUBSCRIPTIONS
-- ============================================================

CREATE TABLE public.subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  tier subscription_tier NOT NULL DEFAULT 'free',
  status subscription_status NOT NULL DEFAULT 'active',
  platform TEXT, -- 'ios' | 'android'
  store_product_id TEXT,
  store_transaction_id TEXT,
  starts_at TIMESTAMPTZ DEFAULT now(),
  expires_at TIMESTAMPTZ,
  trial_ends_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_subscriptions_user ON public.subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON public.subscriptions(status);

-- ============================================================
-- STARDUST ECONOMY
-- ============================================================

CREATE TABLE public.stardust_wallets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  balance INTEGER NOT NULL DEFAULT 0 CHECK (balance >= 0),
  lifetime_earned INTEGER NOT NULL DEFAULT 0,
  lifetime_spent INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.stardust_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  wallet_id UUID NOT NULL REFERENCES public.stardust_wallets(id) ON DELETE CASCADE,
  type transaction_type NOT NULL,
  amount INTEGER NOT NULL,
  balance_after INTEGER NOT NULL,
  description TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_stardust_tx_user ON public.stardust_transactions(user_id);
CREATE INDEX idx_stardust_tx_created ON public.stardust_transactions(created_at DESC);

-- ============================================================
-- NATAL CHARTS (computed once, cached forever)
-- ============================================================

CREATE TABLE public.natal_charts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  birth_date DATE NOT NULL,
  birth_time TIME,
  birth_lat DOUBLE PRECISION NOT NULL,
  birth_lng DOUBLE PRECISION NOT NULL,
  sun_sign zodiac_sign NOT NULL,
  moon_sign zodiac_sign NOT NULL,
  rising_sign zodiac_sign NOT NULL,
  dominant_element element_type,
  planets JSONB NOT NULL,       -- [{planet, sign, degree, house, retrograde}]
  houses JSONB NOT NULL,        -- [{house, sign, degree}]
  aspects JSONB NOT NULL,       -- [{planet1, planet2, type, orb, exact}]
  chart_svg TEXT,               -- pre-rendered chart visual
  aura_color TEXT,
  spiritual_score DOUBLE PRECISION DEFAULT 0,
  computed_at TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- CACHED AI REPORTS
-- ============================================================

CREATE TABLE public.cached_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  report_type report_type NOT NULL,
  ai_provider ai_provider NOT NULL,
  cache_key TEXT NOT NULL,        -- deterministic hash for dedup
  content JSONB NOT NULL,         -- structured report content
  summary TEXT,                   -- short text for previews
  stardust_cost INTEGER DEFAULT 0,
  generation_cost_usd NUMERIC(10, 6) DEFAULT 0,
  input_tokens INTEGER DEFAULT 0,
  output_tokens INTEGER DEFAULT 0,
  valid_until TIMESTAMPTZ,        -- cache TTL
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE UNIQUE INDEX idx_cached_reports_key ON public.cached_reports(cache_key);
CREATE INDEX idx_cached_reports_user ON public.cached_reports(user_id);
CREATE INDEX idx_cached_reports_type ON public.cached_reports(report_type);

-- ============================================================
-- DAILY HOROSCOPES (shared across all users of same sign)
-- ============================================================

CREATE TABLE public.daily_horoscopes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sign zodiac_sign NOT NULL,
  date DATE NOT NULL,
  horoscope_text TEXT NOT NULL,
  energy_score INTEGER CHECK (energy_score BETWEEN 1 AND 100),
  aura_color TEXT,
  lucky_number INTEGER,
  mood TEXT,
  daily_quote TEXT,
  spotify_track_id TEXT,
  spotify_track_name TEXT,
  spotify_artist TEXT,
  spiritual_insight TEXT,
  ai_provider ai_provider DEFAULT 'gemini',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE UNIQUE INDEX idx_daily_horoscope_sign_date ON public.daily_horoscopes(sign, date);

-- ============================================================
-- COMPATIBILITY
-- ============================================================

CREATE TABLE public.compatibility_partners (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  birth_date DATE NOT NULL,
  birth_time TIME,
  birth_city TEXT,
  birth_lat DOUBLE PRECISION,
  birth_lng DOUBLE PRECISION,
  sun_sign zodiac_sign,
  moon_sign zodiac_sign,
  rising_sign zodiac_sign,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_compat_partners_user ON public.compatibility_partners(user_id);

CREATE TABLE public.compatibility_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  partner_id UUID NOT NULL REFERENCES public.compatibility_partners(id) ON DELETE CASCADE,
  overall_score DOUBLE PRECISION CHECK (overall_score BETWEEN 0 AND 100),
  emotional_alignment DOUBLE PRECISION,
  communication_score DOUBLE PRECISION,
  karmic_bond DOUBLE PRECISION,
  intimacy_energy DOUBLE PRECISION,
  soulmate_probability DOUBLE PRECISION,
  conflict_patterns JSONB,
  long_term_score DOUBLE PRECISION,
  energetic_balance DOUBLE PRECISION,
  synastry_data JSONB,
  composite_data JSONB,
  ai_analysis JSONB,
  share_image_url TEXT,
  is_deep_scan BOOLEAN DEFAULT false,
  stardust_cost INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_compat_reports_user ON public.compatibility_reports(user_id);

-- ============================================================
-- MOON PHASES & RITUALS
-- ============================================================

CREATE TABLE public.moon_phases (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  date DATE UNIQUE NOT NULL,
  phase_name TEXT NOT NULL,        -- New Moon, Waxing Crescent, etc.
  phase_percentage DOUBLE PRECISION,
  illumination DOUBLE PRECISION,
  zodiac_sign zodiac_sign,
  ritual_suggestion TEXT,
  manifestation_tip TEXT,
  emotional_guidance TEXT,
  energy_insight TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_moon_phases_date ON public.moon_phases(date);

-- ============================================================
-- BREATHWORK SESSIONS
-- ============================================================

CREATE TABLE public.breathwork_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type breathwork_type NOT NULL,
  duration_seconds INTEGER NOT NULL,
  completed BOOLEAN DEFAULT false,
  mood_before TEXT,
  mood_after TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_breathwork_user ON public.breathwork_sessions(user_id);

-- ============================================================
-- ASTROCARTOGRAPHY
-- ============================================================

CREATE TABLE public.astrocartography_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  planetary_lines JSONB NOT NULL,  -- [{planet, line_type, coordinates}]
  best_cities JSONB,               -- [{city, country, lat, lng, score, category}]
  love_locations JSONB,
  career_locations JSONB,
  spiritual_locations JSONB,
  energy_hotspots JSONB,
  ai_analysis JSONB,
  is_premium BOOLEAN DEFAULT false,
  stardust_cost INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_astrocarto_user ON public.astrocartography_reports(user_id);

-- ============================================================
-- USER STREAKS & ENGAGEMENT
-- ============================================================

CREATE TABLE public.user_streaks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  last_active_date DATE,
  total_sessions INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- NOTIFICATIONS
-- ============================================================

CREATE TABLE public.notification_preferences (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  daily_horoscope BOOLEAN DEFAULT true,
  moon_phases BOOLEAN DEFAULT true,
  transit_alerts BOOLEAN DEFAULT true,
  ritual_reminders BOOLEAN DEFAULT true,
  energy_shifts BOOLEAN DEFAULT true,
  streak_reminders BOOLEAN DEFAULT true,
  promotional BOOLEAN DEFAULT false,
  quiet_hours_start TIME DEFAULT '22:00',
  quiet_hours_end TIME DEFAULT '08:00',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.notification_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  category notification_category NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB DEFAULT '{}',
  sent_at TIMESTAMPTZ DEFAULT now(),
  opened_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_notif_log_user ON public.notification_log(user_id);

-- ============================================================
-- AD REWARDS
-- ============================================================

CREATE TABLE public.ad_rewards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  ad_unit_id TEXT NOT NULL,
  stardust_earned INTEGER NOT NULL,
  watched_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_ad_rewards_user ON public.ad_rewards(user_id);

-- ============================================================
-- ADMIN ANALYTICS (materialized for performance)
-- ============================================================

CREATE TABLE public.admin_daily_metrics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  date DATE UNIQUE NOT NULL,
  total_users INTEGER DEFAULT 0,
  new_users INTEGER DEFAULT 0,
  active_users INTEGER DEFAULT 0,
  premium_users INTEGER DEFAULT 0,
  total_revenue_usd NUMERIC(12, 2) DEFAULT 0,
  stardust_purchased INTEGER DEFAULT 0,
  stardust_spent INTEGER DEFAULT 0,
  ai_cost_usd NUMERIC(10, 4) DEFAULT 0,
  reports_generated INTEGER DEFAULT 0,
  breathwork_sessions INTEGER DEFAULT 0,
  compatibility_scans INTEGER DEFAULT 0,
  avg_session_duration_seconds INTEGER DEFAULT 0,
  retention_d1 NUMERIC(5, 2),
  retention_d7 NUMERIC(5, 2),
  retention_d30 NUMERIC(5, 2),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stardust_wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stardust_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.natal_charts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cached_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.compatibility_partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.compatibility_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.breathwork_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.astrocartography_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ad_rewards ENABLE ROW LEVEL SECURITY;

-- Users can only access their own data
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users own subscriptions" ON public.subscriptions
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users own wallet" ON public.stardust_wallets
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users own transactions" ON public.stardust_transactions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users own natal chart" ON public.natal_charts
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users own reports" ON public.cached_reports
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users own partners" ON public.compatibility_partners
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users own compat reports" ON public.compatibility_reports
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users own breathwork" ON public.breathwork_sessions
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users own astrocarto" ON public.astrocartography_reports
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users own streaks" ON public.user_streaks
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users own notif prefs" ON public.notification_preferences
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users own notif log" ON public.notification_log
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users own ad rewards" ON public.ad_rewards
  FOR ALL USING (auth.uid() = user_id);

-- Daily horoscopes are public (read-only)
ALTER TABLE public.daily_horoscopes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read horoscopes" ON public.daily_horoscopes
  FOR SELECT USING (true);

-- Moon phases are public (read-only)
ALTER TABLE public.moon_phases ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read moon phases" ON public.moon_phases
  FOR SELECT USING (true);

-- ============================================================
-- FUNCTIONS
-- ============================================================

-- Auto-create wallet on profile insert
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.stardust_wallets (user_id, balance)
  VALUES (NEW.id, 50); -- 50 welcome Stardust
  INSERT INTO public.user_streaks (user_id)
  VALUES (NEW.id);
  INSERT INTO public.notification_preferences (user_id)
  VALUES (NEW.id);
  INSERT INTO public.subscriptions (user_id, tier, status)
  VALUES (NEW.id, 'free', 'active');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_profile_created
  AFTER INSERT ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Stardust spend function (atomic)
CREATE OR REPLACE FUNCTION public.spend_stardust(
  p_user_id UUID,
  p_amount INTEGER,
  p_description TEXT DEFAULT ''
)
RETURNS BOOLEAN AS $$
DECLARE
  v_balance INTEGER;
  v_wallet_id UUID;
BEGIN
  SELECT id, balance INTO v_wallet_id, v_balance
  FROM public.stardust_wallets
  WHERE user_id = p_user_id
  FOR UPDATE;

  IF v_balance < p_amount THEN
    RETURN FALSE;
  END IF;

  UPDATE public.stardust_wallets
  SET balance = balance - p_amount,
      lifetime_spent = lifetime_spent + p_amount,
      updated_at = now()
  WHERE user_id = p_user_id;

  INSERT INTO public.stardust_transactions (user_id, wallet_id, type, amount, balance_after, description)
  VALUES (p_user_id, v_wallet_id, 'spend', p_amount, v_balance - p_amount, p_description);

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Stardust earn function (atomic)
CREATE OR REPLACE FUNCTION public.earn_stardust(
  p_user_id UUID,
  p_amount INTEGER,
  p_type transaction_type DEFAULT 'reward',
  p_description TEXT DEFAULT ''
)
RETURNS INTEGER AS $$
DECLARE
  v_balance INTEGER;
  v_wallet_id UUID;
BEGIN
  SELECT id, balance INTO v_wallet_id, v_balance
  FROM public.stardust_wallets
  WHERE user_id = p_user_id
  FOR UPDATE;

  UPDATE public.stardust_wallets
  SET balance = balance + p_amount,
      lifetime_earned = lifetime_earned + p_amount,
      updated_at = now()
  WHERE user_id = p_user_id;

  INSERT INTO public.stardust_transactions (user_id, wallet_id, type, amount, balance_after, description)
  VALUES (p_user_id, v_wallet_id, p_type, p_amount, v_balance + p_amount, p_description);

  RETURN v_balance + p_amount;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Updated at trigger
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.subscriptions
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.stardust_wallets
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.user_streaks
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.notification_preferences
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
