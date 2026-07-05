import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/language_provider.dart';
import '../../../astrocartography/presentation/providers/astrocartography_provider.dart';
import '../../../astrology/domain/entities/birth_map.dart';
import '../../../astrology/presentation/providers/astrology_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../domain/entities/loved_one.dart';

/// Whether a Birth Map has already been generated for this loved one, in
/// any language.
final lovedOneBirthMapExistsProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, lovedOneId) async {
  final result = await ref
      .watch(astrologyRepositoryProvider)
      .hasBirthMapForLovedOne(lovedOneId);
  return result.when(success: (d) => d, failure: (_) => false);
});

/// The generated Birth Map for this loved one in the current app language,
/// if one exists.
final lovedOneBirthMapProvider =
    FutureProvider.autoDispose.family<BirthMap?, String>((ref, lovedOneId) async {
  final language = ref.watch(languageCodeProvider);
  final result = await ref
      .watch(astrologyRepositoryProvider)
      .getBirthMapForLovedOne(lovedOneId, language: language);
  return result.when(success: (d) => d, failure: (_) => null);
});

/// Whether Astrocartography has already been unlocked for this loved one.
final lovedOneAstroUnlockedProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, lovedOneId) async {
  final result = await ref
      .watch(astrocartographyRepositoryProvider)
      .hasUnlockForLovedOne(lovedOneId);
  return result.when(success: (d) => d, failure: (_) => false);
});

class GenerateLovedOneBirthMapNotifier extends StateNotifier<AsyncValue<void>> {
  GenerateLovedOneBirthMapNotifier(this._ref)
      : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> generate(LovedOne lovedOne) async {
    state = const AsyncValue.loading();
    final language = _ref.read(languageCodeProvider);

    final result = await _ref.read(astrologyRepositoryProvider).generateBirthMapForLovedOne(
          lovedOneId: lovedOne.id,
          sunSign: lovedOne.sunSign,
          moonSign: lovedOne.moonSign,
          risingSign: lovedOne.risingSign,
          mcSign: lovedOne.mcSign ?? '',
          birthDate: lovedOne.birthDate.toIso8601String().split('T').first,
          birthCity: lovedOne.birthCity,
          language: language,
        );

    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        _ref.invalidate(lovedOneBirthMapProvider(lovedOne.id));
        _ref.invalidate(lovedOneBirthMapExistsProvider(lovedOne.id));
        _ref.invalidate(stardustBalanceProvider);
        return true;
      },
      failure: (f) {
        state = AsyncValue.error(f.toString(), StackTrace.current);
        return false;
      },
    );
  }
}

final generateLovedOneBirthMapProvider = StateNotifierProvider.autoDispose
    .family<GenerateLovedOneBirthMapNotifier, AsyncValue<void>, String>(
        (ref, lovedOneId) {
  return GenerateLovedOneBirthMapNotifier(ref);
});
