import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/di.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../stardust/presentation/providers/stardust_provider.dart';
import '../../data/repositories/astrocartography_repository_impl.dart';
import '../../domain/entities/astrocartography_lines.dart';
import '../../domain/entities/astrocartography_unlock.dart';
import '../../domain/repositories/astrocartography_repository.dart';

final astrocartographyRepositoryProvider =
    Provider<AstrocartographyRepository>((ref) {
  return AstrocartographyRepositoryImpl(ref.watch(supabaseClientProvider));
});

/// History of every birth-data version the user has unlocked Astrocartography
/// for, newest first.
final astrocartographyHistoryProvider =
    FutureProvider<List<AstrocartographyUnlock>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final result =
      await ref.watch(astrocartographyRepositoryProvider).getHistory(user.id);
  return result.when(success: (d) => d, failure: (_) => []);
});

/// Lightweight check for whether the user has already unlocked
/// Astrocartography for their CURRENT birth-data version — used by the Home
/// screen banner so it can show "View" instead of the Stardust cost once
/// already purchased, without needing the full [AstrocartographyNotifier].
final astrocartographyUnlockedProvider = FutureProvider.autoDispose<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  final version = ref.watch(userProfileProvider).valueOrNull?.birthDataVersion ?? 0;
  final result = await ref
      .watch(astrocartographyRepositoryProvider)
      .hasUnlock(userId: user.id, birthDataVersion: version);
  return result.when(success: (d) => d, failure: (_) => false);
});

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
  final AstrocartographyRepository _repo;
  final String _userId;
  final int _birthDataVersion;
  final String? _birthCity;
  final String? _lovedOneId;
  final Ref _ref;

  AstrocartographyNotifier(
    this._repo,
    this._userId,
    this._birthDataVersion,
    this._birthCity,
    this._lovedOneId,
    this._ref,
  ) : super(const AstrocartographyState()) {
    _checkUnlock();
  }

  Future<void> _checkUnlock() async {
    if (_userId.isEmpty) {
      state = const AstrocartographyState(status: AstrocartographyStatus.locked);
      return;
    }
    final result = _lovedOneId != null
        ? await _repo.hasUnlockForLovedOne(_lovedOneId)
        : await _repo.hasUnlock(
            userId: _userId,
            birthDataVersion: _birthDataVersion,
          );
    final unlocked = result.when(success: (d) => d, failure: (_) => false);
    state = AstrocartographyState(
      status: unlocked
          ? AstrocartographyStatus.unlocked
          : AstrocartographyStatus.locked,
    );
  }

  Future<String?> unlock() async {
    if (_userId.isEmpty) return 'astro_not_logged_in'.tr();
    state = const AstrocartographyState(status: AstrocartographyStatus.loading);
    final result = _lovedOneId != null
        ? await _repo.unlockForLovedOne(lovedOneId: _lovedOneId, amount: 100)
        : await _repo.unlock(
            userId: _userId,
            amount: 100,
            birthCity: _birthCity,
          );
    return result.when(
      success: (_) async {
        state = const AstrocartographyState(
            status: AstrocartographyStatus.unlocked);
        _ref.invalidate(stardustBalanceProvider);
        _ref.invalidate(stardustTransactionsProvider);
        _ref.invalidate(astrocartographyHistoryProvider);
        return null;
      },
      failure: (f) async {
        if (f.toString().toLowerCase().contains('insufficient')) {
          final msg = 'astro_not_enough_earn'.tr();
          state = AstrocartographyState(status: AstrocartographyStatus.locked, error: msg);
          return msg;
        }

        // A client-side error doesn't necessarily mean the unlock failed
        // server-side (dropped connection, slow response) — check actual
        // state before showing an error for something that may have
        // actually succeeded.
        final checkResult = _lovedOneId != null
            ? await _repo.hasUnlockForLovedOne(_lovedOneId)
            : await _repo.hasUnlock(userId: _userId, birthDataVersion: _birthDataVersion);
        final actuallyUnlocked = checkResult.when(success: (d) => d, failure: (_) => false);
        if (actuallyUnlocked) {
          state = const AstrocartographyState(status: AstrocartographyStatus.unlocked);
          _ref.invalidate(stardustBalanceProvider);
          _ref.invalidate(stardustTransactionsProvider);
          _ref.invalidate(astrocartographyHistoryProvider);
          return null;
        }

        final msg = 'astro_try_again'.tr();
        state = AstrocartographyState(status: AstrocartographyStatus.locked, error: msg);
        return msg;
      },
    );
  }
}

/// Keyed by loved-one id (null = the current user's own Astrocartography).
final astrocartographyProvider = StateNotifierProvider.autoDispose
    .family<AstrocartographyNotifier, AstrocartographyState, String?>(
        (ref, lovedOneId) {
  final user = ref.watch(currentUserProvider);
  final profile = ref.watch(userProfileProvider).valueOrNull;
  return AstrocartographyNotifier(
    ref.watch(astrocartographyRepositoryProvider),
    user?.id ?? '',
    profile?.birthDataVersion ?? 0,
    profile?.birthCity,
    lovedOneId,
    ref,
  );
});

/// Real, computed astrocartography lines for the given birth data (self or
/// a Loved One). Returns null while birth data is incomplete or on error —
/// callers should only watch this once [AstrocartographyStatus.unlocked].
typedef AstrocartographyLinesParams = ({
  String? lovedOneId,
  DateTime? birthDate,
  String? birthTime,
  String? birthCity,
});

final astrocartographyLinesProvider = FutureProvider.autoDispose
    .family<AstrocartographyLines?, AstrocartographyLinesParams>((ref, params) async {
  if (params.birthDate == null || params.birthTime == null || params.birthCity == null) {
    return null;
  }
  final result = await ref.watch(astrocartographyRepositoryProvider).getLines(
        birthDate: params.birthDate!,
        birthTime: params.birthTime!,
        birthCity: params.birthCity!,
        lovedOneId: params.lovedOneId,
      );
  return result.when(success: (d) => d, failure: (_) => null);
});
