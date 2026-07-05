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

/// True if the user already has a daily_login transaction for today.
///
/// The server (`claim_daily_checkin` RPC) gates eligibility on Postgres'
/// `CURRENT_DATE`, and the database's session timezone is UTC — so "today"
/// here must also be computed in UTC. Comparing against local time would
/// mismatch for anyone several hours off UTC (e.g. Turkey, UTC+3): the tile
/// would show as still unclaimed after already checking in, and tapping it
/// again would be rejected by the server as "already claimed".
final hasCheckedInTodayProvider = FutureProvider<bool>((ref) async {
  final transactions = await ref.watch(stardustTransactionsProvider.future);
  final todayUtc = DateTime.now().toUtc();
  return transactions.any((tx) {
    final utc = tx.createdAt.toUtc();
    return tx.source == 'daily_login' &&
        utc.year == todayUtc.year &&
        utc.month == todayUtc.month &&
        utc.day == todayUtc.day;
  });
});
