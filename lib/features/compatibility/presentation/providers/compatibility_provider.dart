import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/di.dart';
import '../../data/repositories/compatibility_repository_impl.dart';
import '../../domain/entities/compatibility_partner.dart';
import '../../domain/repositories/compatibility_repository.dart';

final compatibilityRepositoryProvider = Provider<CompatibilityRepository>((ref) {
  return CompatibilityRepositoryImpl(ref.watch(supabaseClientProvider));
});

final partnersProvider =
    FutureProvider<List<CompatibilityPartner>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final result =
      await ref.watch(compatibilityRepositoryProvider).getPartners(user.id);
  return result.when(success: (d) => d, failure: (_) => []);
});
