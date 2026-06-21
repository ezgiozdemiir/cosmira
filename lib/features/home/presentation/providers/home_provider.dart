import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/di.dart';
import '../../../../core/providers/language_provider.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/daily_horoscope.dart';
import '../../domain/repositories/home_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(ref.watch(supabaseClientProvider));
});

final todayHoroscopeProvider = FutureProvider<DailyHoroscope?>((ref) async {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  if (profile?.sunSign == null) return null;
  final language = ref.watch(languageCodeProvider);

  final result = await ref
      .watch(homeRepositoryProvider)
      .getTodayHoroscope(profile!.sunSign!, language: language);
  return result.when(success: (d) => d, failure: (_) => null);
});

final stardustBalanceProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;

  final result =
      await ref.watch(homeRepositoryProvider).getStardustBalance(user.id);
  return result.when(success: (d) => d, failure: (_) => 0);
});

final streakProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;

  final result = await ref.watch(homeRepositoryProvider).getStreak(user.id);
  return result.when(success: (d) => d, failure: (_) => 0);
});
