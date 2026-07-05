import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/di.dart';
import '../../../astrology/domain/entities/big_three_result.dart';
import '../../../astrology/domain/repositories/astrology_repository.dart';
import '../../../astrology/presentation/providers/astrology_provider.dart';
import '../../data/repositories/loved_ones_repository_impl.dart';
import '../../domain/entities/loved_one.dart';
import '../../domain/repositories/loved_ones_repository.dart';

final lovedOnesRepositoryProvider = Provider<LovedOnesRepository>((ref) {
  return LovedOnesRepositoryImpl(ref.watch(supabaseClientProvider));
});

/// All loved ones the current user has saved, newest first.
final lovedOnesProvider = FutureProvider.autoDispose<List<LovedOne>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final result = await ref.watch(lovedOnesRepositoryProvider).getAll(user.id);
  return result.when(success: (d) => d, failure: (_) => []);
});

/// A single saved loved one by id, looked up from the already-loaded list.
final lovedOneByIdProvider =
    FutureProvider.autoDispose.family<LovedOne?, String>((ref, id) async {
  final list = await ref.watch(lovedOnesProvider.future);
  for (final lovedOne in list) {
    if (lovedOne.id == id) return lovedOne;
  }
  return null;
});

// ---------------------------------------------------------------------------
// Add loved one notifier
// ---------------------------------------------------------------------------

class AddLovedOneNotifier extends StateNotifier<AsyncValue<void>> {
  AddLovedOneNotifier(this._repo, this._astrologyRepo, this._ref)
      : super(const AsyncValue.data(null));

  final LovedOnesRepository _repo;
  final AstrologyRepository _astrologyRepo;
  final Ref _ref;

  /// Computes the loved one's full chart (Sun/Moon/Rising/MC + geocoded
  /// lat/lng) via the same `calculate-natal-chart` edge function used for
  /// the user's own onboarding, then saves the loved one. Rows are
  /// immutable once created, so this is the only chance to get it right.
  Future<bool> add({
    required String name,
    String? gender,
    required DateTime birthDate,
    required TimeOfDay birthTime,
    required String birthCity,
  }) async {
    state = const AsyncValue.loading();

    final user = _ref.read(currentUserProvider);
    if (user == null) {
      state = AsyncValue.error('Not logged in', StackTrace.current);
      return false;
    }

    final birthTimeStr =
        '${birthTime.hour.toString().padLeft(2, '0')}:${birthTime.minute.toString().padLeft(2, '0')}';

    final bigThreeResult = await _astrologyRepo.calculateBigThree(
      birthDate: birthDate,
      birthTime: birthTimeStr,
      birthCity: birthCity.trim(),
    );

    BigThreeResult? bigThree;
    bigThreeResult.when(
      success: (d) => bigThree = d,
      failure: (f) => state = AsyncValue.error(f.toString(), StackTrace.current),
    );
    if (bigThree == null) return false;

    final addResult = await _repo.add(
      userId: user.id,
      name: name.trim(),
      gender: gender,
      birthDate: birthDate,
      birthTime: birthTimeStr,
      birthCity: birthCity.trim(),
      birthLat: bigThree!.birthLat,
      birthLng: bigThree!.birthLng,
      sunSign: bigThree!.sunSign,
      moonSign: bigThree!.moonSign,
      risingSign: bigThree!.risingSign,
      mcSign: bigThree!.mcSign,
    );

    return addResult.when(
      success: (_) {
        state = const AsyncValue.data(null);
        _ref.invalidate(lovedOnesProvider);
        return true;
      },
      failure: (f) {
        state = AsyncValue.error(f.toString(), StackTrace.current);
        return false;
      },
    );
  }
}

final addLovedOneProvider = StateNotifierProvider.autoDispose<
    AddLovedOneNotifier, AsyncValue<void>>((ref) {
  return AddLovedOneNotifier(
    ref.watch(lovedOnesRepositoryProvider),
    ref.watch(astrologyRepositoryProvider),
    ref,
  );
});
