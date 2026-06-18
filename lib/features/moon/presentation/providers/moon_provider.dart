import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/di.dart';
import '../../data/repositories/moon_repository_impl.dart';
import '../../domain/entities/moon_phase.dart';
import '../../domain/moon_calculator.dart';
import '../../domain/repositories/moon_repository.dart';

final moonRepositoryProvider = Provider<MoonRepository>((ref) {
  return MoonRepositoryImpl(ref.watch(supabaseClientProvider));
});

// ---------------------------------------------------------------------------
// Local (offline) providers — no DB required
// ---------------------------------------------------------------------------

/// The selected calendar month (year + month, day is always 1).
final selectedMonthProvider = StateProvider<DateTime>(
  (ref) => DateTime(DateTime.now().year, DateTime.now().month),
);

/// The selected day in the calendar (defaults to today).
final selectedDayProvider = StateProvider<DateTime>(
  (ref) => DateTime.now(),
);

/// Today's moon phase, computed locally.
final localCurrentMoonPhaseProvider = Provider<MoonPhase>(
  (ref) => MoonCalculator.forDate(DateTime.now()),
);

/// Moon phase for the currently selected calendar day.
final selectedDayMoonPhaseProvider = Provider<MoonPhase>((ref) {
  return MoonCalculator.forDate(ref.watch(selectedDayProvider));
});

/// All daily moon phases for the selected month.
final localMonthlyPhasesProvider = Provider<List<MoonPhase>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return MoonCalculator.forMonth(month.year, month.month);
});

// ---------------------------------------------------------------------------
// DB-backed providers (kept for future use when moon_phases table is seeded)
// ---------------------------------------------------------------------------

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
