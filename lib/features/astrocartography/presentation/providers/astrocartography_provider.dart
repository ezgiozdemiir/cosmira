import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/di.dart';
import '../../../stardust/domain/repositories/stardust_repository.dart';
import '../../../stardust/presentation/providers/stardust_provider.dart';

enum AstrocartographyStatus { loading, locked, unlocked }

class AstrocartographyState {
  final AstrocartographyStatus status;
  final String? error;
  const AstrocartographyState({
    this.status = AstrocartographyStatus.loading,
    this.error,
  });
  AstrocartographyState copyWith({AstrocartographyStatus? status, String? error}) =>
      AstrocartographyState(status: status ?? this.status, error: error);
}

class AstrocartographyNotifier
    extends StateNotifier<AstrocartographyState> {
  final StardustRepository _repo;
  final String _userId;

  AstrocartographyNotifier(this._repo, this._userId)
      : super(const AstrocartographyState()) {
    _checkUnlock();
  }

  Future<void> _checkUnlock() async {
    if (_userId.isEmpty) {
      state = const AstrocartographyState(status: AstrocartographyStatus.locked);
      return;
    }
    final result = await _repo.getTransactions(_userId);
    final unlocked = result.when(
      success: (list) =>
          list.any((t) => !t.isEarning && t.description.contains('Astrocartography')),
      failure: (_) => false,
    );
    state = AstrocartographyState(
      status: unlocked
          ? AstrocartographyStatus.unlocked
          : AstrocartographyStatus.locked,
    );
  }

  Future<String?> unlock() async {
    if (_userId.isEmpty) return 'Not logged in';
    state = const AstrocartographyState(status: AstrocartographyStatus.loading);
    final result = await _repo.spendStardust(
      userId: _userId,
      amount: 100,
      description: 'Astrocartography Full Report',
    );
    return result.when(
      success: (_) {
        state = const AstrocartographyState(
            status: AstrocartographyStatus.unlocked);
        return null;
      },
      failure: (f) {
        final msg = f.toString().toLowerCase().contains('insufficient')
            ? 'Not enough Stardust. Earn more in the Stardust Store.'
            : 'Something went wrong. Please try again.';
        state = AstrocartographyState(
            status: AstrocartographyStatus.locked, error: msg);
        return msg;
      },
    );
  }
}

final astrocartographyProvider = StateNotifierProvider.autoDispose<
    AstrocartographyNotifier, AstrocartographyState>((ref) {
  final user = ref.watch(currentUserProvider);
  return AstrocartographyNotifier(
    ref.watch(stardustRepositoryProvider),
    user?.id ?? '',
  );
});
