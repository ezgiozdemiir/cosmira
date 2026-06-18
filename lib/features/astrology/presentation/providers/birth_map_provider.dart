import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/di.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../domain/entities/birth_map.dart';
import '../../domain/repositories/astrology_repository.dart';
import 'astrology_provider.dart';

/// Lightweight existence check — avoids fetching the full content blob
/// when only the entry card on the natal chart screen needs to know.
final birthMapExistsProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  final result =
      await ref.watch(astrologyRepositoryProvider).hasBirthMap(user.id);
  return result.when(success: (d) => d, failure: (_) => false);
});

/// Full birth map — only watched from BirthMapScreen.
final birthMapProvider = FutureProvider<BirthMap?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final result =
      await ref.watch(astrologyRepositoryProvider).getBirthMap(user.id);
  return result.when(success: (d) => d, failure: (_) => null);
});

// ---------------------------------------------------------------------------
// Purchase notifier
// ---------------------------------------------------------------------------

@immutable
class BirthMapPurchaseState {
  final bool isLoading;
  final String? error;

  const BirthMapPurchaseState({this.isLoading = false, this.error});

  BirthMapPurchaseState copyWith({bool? isLoading, String? error}) =>
      BirthMapPurchaseState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class BirthMapPurchaseNotifier
    extends StateNotifier<BirthMapPurchaseState> {
  final AstrologyRepository _repo;
  final Ref _ref;

  BirthMapPurchaseNotifier(this._repo, this._ref)
      : super(const BirthMapPurchaseState());

  /// Returns `true` on success, `false` on error.
  Future<bool> purchase({
    required String sunSign,
    required String moonSign,
    required String risingSign,
    required String mcSign,
    required String birthDate,
    required String birthCity,
  }) async {
    state = const BirthMapPurchaseState(isLoading: true);

    final result = await _repo.generateBirthMap(
      sunSign: sunSign,
      moonSign: moonSign,
      risingSign: risingSign,
      mcSign: mcSign,
      birthDate: birthDate,
      birthCity: birthCity,
    );

    return result.when(
      success: (_) {
        state = const BirthMapPurchaseState();
        _ref.invalidate(birthMapProvider);
        _ref.invalidate(birthMapExistsProvider);
        _ref.invalidate(stardustBalanceProvider);
        return true;
      },
      failure: (f) {
        final raw = f.toString();
        final msg = raw.contains('insufficient_stardust')
            ? 'Not enough Stardust. Visit the store to top up.'
            : 'Something went wrong. Please try again.';
        state = BirthMapPurchaseState(error: msg);
        return false;
      },
    );
  }
}

final birthMapPurchaseProvider = StateNotifierProvider.autoDispose<
    BirthMapPurchaseNotifier, BirthMapPurchaseState>((ref) {
  return BirthMapPurchaseNotifier(
    ref.watch(astrologyRepositoryProvider),
    ref,
  );
});
