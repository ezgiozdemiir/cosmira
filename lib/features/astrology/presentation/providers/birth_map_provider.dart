import 'package:easy_localization/easy_localization.dart';
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

/// Returns true if the user has purchased a birth map for their CURRENT
/// birth data (in any language). Editing birth data bumps the version, so
/// this correctly goes back to false until the user pays again.
final birthMapExistsProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  final profile = ref.watch(userProfileProvider).valueOrNull;
  final result = await ref
      .watch(astrologyRepositoryProvider)
      .hasBirthMap(user.id, birthDataVersion: profile?.birthDataVersion ?? 0);
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
  final profile = ref.read(userProfileProvider).valueOrNull;
  final birthDataVersion = profile?.birthDataVersion ?? 0;

  final result = await repo.getBirthMap(user.id, language: language, birthDataVersion: birthDataVersion);
  final existing = result.when(success: (d) => d, failure: (_) => null);
  if (existing != null) return existing;

  // No version for this language yet — check if user has paid for this
  // birth-data version (any language)
  final paidResult = await repo.hasBirthMap(user.id, birthDataVersion: birthDataVersion);
  final hasPaid = paidResult.when(success: (d) => d, failure: (_) => false);
  if (!hasPaid) return null;

  // User already paid — generate the missing language for free
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

/// One entry per birth-data version ever purchased, newest first — feeds the
/// Birth Map history list.
final birthMapHistoryProvider = FutureProvider<List<BirthMap>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final result =
      await ref.watch(astrologyRepositoryProvider).getBirthMapHistory(user.id);
  return result.when(success: (d) => d, failure: (_) => []);
});

/// Read-only lookup of a specific past birth-data version's report, for the
/// history screen. Falls back to any available language for that version.
final birthMapAtVersionProvider =
    FutureProvider.family<BirthMap?, int>((ref, version) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final language = ref.watch(languageCodeProvider);
  final repo = ref.watch(astrologyRepositoryProvider);

  final result = await repo.getBirthMap(user.id, language: language, birthDataVersion: version);
  final existing = result.when(success: (d) => d, failure: (_) => null);
  if (existing != null) return existing;

  final history = await ref.watch(birthMapHistoryProvider.future);
  for (final map in history) {
    if (map.birthDataVersion == version) return map;
  }
  return null;
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
      success: (_) async {
        state = const BirthMapPurchaseState();
        _ref.invalidate(birthMapProvider);
        _ref.invalidate(birthMapExistsProvider);
        _ref.invalidate(stardustBalanceProvider);
        return true;
      },
      failure: (f) async {
        final raw = f.toString();
        final isInsufficient = raw.contains('insufficient_stardust');
        if (isInsufficient) {
          state = BirthMapPurchaseState(error: 'bm_purchase_insufficient'.tr());
          return false;
        }

        // A client-side error here (dropped connection, slow response, a
        // parsing hiccup) doesn't necessarily mean the server-side purchase
        // failed — spend_stardust + generation + insert may have completed
        // fine and only the client's view of the response failed. Check
        // actual server state before showing a scary error for something
        // that may have actually succeeded.
        final user = _ref.read(currentUserProvider);
        final version = _ref.read(userProfileProvider).valueOrNull?.birthDataVersion ?? 0;
        if (user != null) {
          final existsResult = await _repo.hasBirthMap(user.id, birthDataVersion: version);
          final actuallySucceeded = existsResult.when(success: (d) => d, failure: (_) => false);
          if (actuallySucceeded) {
            state = const BirthMapPurchaseState();
            _ref.invalidate(birthMapProvider);
            _ref.invalidate(birthMapExistsProvider);
            _ref.invalidate(stardustBalanceProvider);
            _ref.invalidate(stardustTransactionsProvider);
            return true;
          }
        }

        state = BirthMapPurchaseState(error: 'bm_purchase_error'.tr());
        _ref.invalidate(stardustBalanceProvider);
        _ref.invalidate(stardustTransactionsProvider);
        _ref.invalidate(birthMapProvider);
        _ref.invalidate(birthMapExistsProvider);
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
