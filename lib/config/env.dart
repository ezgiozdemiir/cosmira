abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
  static const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const openaiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const revenueCatApiKey = String.fromEnvironment('REVENUECAT_API_KEY');
  static const spotifyClientId = String.fromEnvironment('SPOTIFY_CLIENT_ID');
  static const spotifyRedirectUri = String.fromEnvironment('SPOTIFY_REDIRECT_URI');
  static const admobBannerId = String.fromEnvironment('ADMOB_BANNER_ID');
  static const admobRewardedId = String.fromEnvironment('ADMOB_REWARDED_ID');
}
