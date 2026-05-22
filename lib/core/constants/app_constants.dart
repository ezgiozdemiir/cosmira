abstract final class AppConstants {
  static const appName = 'Cosmira';
  static const stardustDailyLoginReward = 5;
  static const stardustAdReward = 10;
  static const stardustReferralReward = 50;
  static const maxFreeCompatibilityPartners = 2;
  static const maxPremiumCompatibilityPartners = 10;
  static const freeBreathworkSessionsPerDay = 1;
  static const premiumBreathworkSessionsPerDay = -1; // unlimited
  static const dailyHoroscopeRefreshHourUtc = 0;
  static const natalChartCacheDurationDays = -1; // forever
  static const compatibilityReportCacheDays = 90;
  static const yearlyReportCacheDays = 365;
  static const maxStreakDays = 365;
}

abstract final class SupabaseTables {
  static const profiles = 'profiles';
  static const subscriptions = 'subscriptions';
  static const stardustWallets = 'stardust_wallets';
  static const stardustTransactions = 'stardust_transactions';
  static const natalCharts = 'natal_charts';
  static const cachedReports = 'cached_reports';
  static const dailyHoroscopes = 'daily_horoscopes';
  static const compatibilityPartners = 'compatibility_partners';
  static const compatibilityReports = 'compatibility_reports';
  static const moonPhases = 'moon_phases';
  static const breathworkSessions = 'breathwork_sessions';
  static const userStreaks = 'user_streaks';
  static const notificationPreferences = 'notification_preferences';
  static const notificationLog = 'notification_log';
  static const adRewards = 'ad_rewards';
}
