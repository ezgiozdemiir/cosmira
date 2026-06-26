import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/di.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../stardust/presentation/providers/stardust_provider.dart';
import '../../domain/entities/birth_map.dart';
import '../../domain/repositories/astrology_repository.dart';
import 'astrology_provider.dart';

/// Returns true if the user has purchased a birth map in ANY language.
final birthMapExistsProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  final result = await ref
      .watch(astrologyRepositoryProvider)
      .hasBirthMap(user.id);
  return result.when(success: (d) => d, failure: (_) => false);
});

/// Full birth map — only watched from BirthMapScreen.
/// Auto-generates the current language version if the user has already paid
/// but only has a different language version cached.
final birthMapProvider = FutureProvider<BirthMap?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final language = ref.watch(languageCodeProvider);
  final repo = ref.watch(astrologyRepositoryProvider);

  final result = await repo.getBirthMap(user.id, language: language);
  final existing = result.when(success: (d) => d, failure: (_) => null);
  if (existing != null) return existing;

  // No version for this language yet — check if user has paid (any language)
  final paidResult = await repo.hasBirthMap(user.id);
  final hasPaid = paidResult.when(success: (d) => d, failure: (_) => false);
  if (!hasPaid) return null;

  // User already paid — generate the missing language for free
  final profile = ref.read(userProfileProvider).valueOrNull;
  if (profile == null) return null;

  final genResult = await repo.generateBirthMap(
    sunSign: profile.sunSign ?? '',
    moonSign: profile.moonSign ?? '',
    risingSign: profile.risingSign ?? '',
    mcSign: profile.mcSign ?? '',
    birthDate: profile.birthDate?.toIso8601String().split('T').first ?? '',
    birthCity: profile.birthCity ?? '',
    language: language,
  );
  return genResult.when(success: (d) => d, failure: (_) => null);
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
    final language = _ref.read(languageCodeProvider);

    final result = await _repo.generateBirthMap(
      sunSign: sunSign,
      moonSign: moonSign,
      risingSign: risingSign,
      mcSign: mcSign,
      birthDate: birthDate,
      birthCity: birthCity,
      language: language,
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
        final isInsufficient = raw.contains('insufficient_stardust');
        final msg = isInsufficient
            ? 'Not enough Stardust. Visit the store to top up.'
            : 'Something went wrong. Please try again.';
        state = BirthMapPurchaseState(error: msg);
        // If it's not an insufficient-stardust error, stardust may have been
        // deducted and the birth map may have been inserted server-side even
        // though the response failed. Refresh so the UI reflects actual state.
        if (!isInsufficient) {
          _ref.invalidate(stardustBalanceProvider);
          _ref.invalidate(stardustTransactionsProvider);
          _ref.invalidate(birthMapProvider);
          _ref.invalidate(birthMapExistsProvider);
        }
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
