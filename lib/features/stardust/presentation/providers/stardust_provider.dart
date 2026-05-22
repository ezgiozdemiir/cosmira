import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/di.dart';
import '../../data/repositories/stardust_repository_impl.dart';
import '../../domain/entities/stardust_transaction.dart';
import '../../domain/repositories/stardust_repository.dart';

final stardustRepositoryProvider = Provider<StardustRepository>((ref) {
  return StardustRepositoryImpl(ref.watch(supabaseClientProvider));
});

final stardustTransactionsProvider =
    FutureProvider<List<StardustTransaction>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final result =
      await ref.watch(stardustRepositoryProvider).getTransactions(user.id);
  return result.when(success: (d) => d, failure: (_) => []);
});
