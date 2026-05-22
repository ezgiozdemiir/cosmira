import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/di.dart';
import '../../data/repositories/astrology_repository_impl.dart';
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
