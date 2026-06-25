import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/di.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/domain/entities/daily_horoscope.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../data/repositories/astrology_repository_impl.dart';
import '../../domain/entities/big_three_insight.dart';
import '../../domain/entities/house_insight.dart';
import '../../domain/entities/natal_chart.dart';
import '../../domain/repositories/astrology_repository.dart';

final astrologyRepositoryProvider = Provider<AstrologyRepository>((ref) {
  return AstrologyRepositoryImpl(ref.watch(supabaseClientProvider));
});

final natalChartProvider = FutureProvider<NatalChart?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final result =
      await ref.watch(astrologyRepositoryProvider).getNatalChart(user.id);
  return result.when(success: (d) => d, failure: (_) => null);
});

final moonHoroscopeProvider = FutureProvider<DailyHoroscope?>((ref) async {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  if (profile?.moonSign == null) return null;
  final language = ref.watch(languageCodeProvider);

  final result = await ref
      .watch(homeRepositoryProvider)
      .getTodayHoroscope(profile!.moonSign!, point: 'moon', language: language);
  return result.when(success: (d) => d, failure: (_) => null);
});

final risingHoroscopeProvider = FutureProvider<DailyHoroscope?>((ref) async {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  if (profile?.risingSign == null) return null;
  final language = ref.watch(languageCodeProvider);

  final result = await ref
      .watch(homeRepositoryProvider)
      .getTodayHoroscope(profile!.risingSign!, point: 'rising', language: language);
  return result.when(success: (d) => d, failure: (_) => null);
});

Future<BigThreeInsight?> _fetchBigThreeInsight(
  Ref ref, {
  required String tier,
  required String period,
}) async {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  if (profile?.sunSign == null ||
      profile?.moonSign == null ||
      profile?.risingSign == null) {
    return null;
  }
  final language = ref.watch(languageCodeProvider);

  final result = await ref.watch(astrologyRepositoryProvider).getBigThreeInsight(
        sunSign: profile!.sunSign!,
        moonSign: profile.moonSign!,
        risingSign: profile.risingSign!,
        tier: tier,
        period: period,
        language: language,
      );
  return result.when(
    success: (d) => d,
    failure: (f) {
      debugPrint('getBigThreeInsight $period error: ${f.message}');
      return null;
    },
  );
}

final dailyInsightProvider = FutureProvider<BigThreeInsight?>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  final tier = (profile?.isPremium == true) ? 'premium' : 'free';
  return _fetchBigThreeInsight(ref, tier: tier, period: 'daily');
});

final monthlyInsightProvider = FutureProvider<BigThreeInsight?>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  final tier = (profile?.isPremium == true) ? 'premium' : 'free';
  return _fetchBigThreeInsight(ref, tier: tier, period: 'monthly');
});

final yearlyInsightProvider = FutureProvider<BigThreeInsight?>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  final tier = (profile?.isPremium == true) ? 'premium' : 'free';
  return _fetchBigThreeInsight(ref, tier: tier, period: 'yearly');
});

final houseInsightsProvider = FutureProvider<HouseInsight?>((ref) async {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  if (profile?.isPremium != true || profile?.risingSign == null) return null;
  final language = ref.watch(languageCodeProvider);

  final result = await ref
      .watch(astrologyRepositoryProvider)
      .getHouseInsights(risingSign: profile!.risingSign!, language: language);
  return result.when(success: (d) => d, failure: (_) => null);
});
