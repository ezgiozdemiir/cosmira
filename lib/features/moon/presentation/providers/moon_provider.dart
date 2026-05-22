import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/di.dart';
import '../../data/repositories/moon_repository_impl.dart';
import '../../domain/entities/moon_phase.dart';
import '../../domain/repositories/moon_repository.dart';

final moonRepositoryProvider = Provider<MoonRepository>((ref) {
  return MoonRepositoryImpl(ref.watch(supabaseClientProvider));
});

final currentMoonPhaseProvider = FutureProvider<MoonPhase?>((ref) async {
  final result = await ref.watch(moonRepositoryProvider).getCurrentMoonPhase();
  return result.when(success: (d) => d, failure: (_) => null);
});

final monthlyPhasesProvider =
    FutureProvider.family<List<MoonPhase>, ({int year, int month})>(
  (ref, params) async {
    final result = await ref
        .watch(moonRepositoryProvider)
        .getMonthlyPhases(params.year, params.month);
    return result.when(success: (d) => d, failure: (_) => []);
  },
);
