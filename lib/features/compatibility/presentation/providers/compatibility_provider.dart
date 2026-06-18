import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/di.dart';
import '../../../../core/utils/zodiac_utils.dart';
import '../../data/repositories/compatibility_repository_impl.dart';
import '../../domain/entities/compatibility_partner.dart';
import '../../domain/repositories/compatibility_repository.dart';

// Re-export so detail screen only needs one import
export '../../domain/entities/compatibility_partner.dart'
    show CompatibilityReport;

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

// ---------------------------------------------------------------------------
// Add partner notifier
// ---------------------------------------------------------------------------

class AddPartnerNotifier extends StateNotifier<AsyncValue<void>> {
  AddPartnerNotifier(this._repo, this._ref)
      : super(const AsyncValue.data(null));

  final CompatibilityRepository _repo;
  final Ref _ref;

  Future<bool> addPartner({
    required String name,
    required DateTime birthDate,
    required String relationship,
    String? birthCity,
  }) async {
    state = const AsyncValue.loading();

    final user = _ref.read(currentUserProvider);
    if (user == null) {
      state = AsyncValue.error('Not logged in', StackTrace.current);
      return false;
    }

    final partner = CompatibilityPartner(
      id: '',
      userId: user.id,
      name: name.trim(),
      birthDate: birthDate,
      sunSign: sunSignFromDate(birthDate),
      relationship: relationship,
      birthCity: birthCity?.trim().isEmpty == true ? null : birthCity?.trim(),
      createdAt: DateTime.now(),
    );

    final result = await _repo.addPartner(partner);
    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        _ref.invalidate(partnersProvider);
        return true;
      },
      failure: (f) {
        state = AsyncValue.error(f.toString(), StackTrace.current);
        return false;
      },
    );
  }
}

final addPartnerProvider = StateNotifierProvider.autoDispose<
    AddPartnerNotifier, AsyncValue<void>>((ref) {
  return AddPartnerNotifier(
    ref.watch(compatibilityRepositoryProvider),
    ref,
  );
});

// ---------------------------------------------------------------------------
// Compatibility report
// ---------------------------------------------------------------------------

final compatibilityReportProvider =
    FutureProvider.autoDispose.family<CompatibilityReport?, String>(
        (ref, partnerId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final result = await ref
      .watch(compatibilityRepositoryProvider)
      .getReport(user.id, partnerId);
  return result.when(success: (d) => d, failure: (_) => null);
});

class GenerateReportNotifier extends StateNotifier<AsyncValue<void>> {
  GenerateReportNotifier(this._repo, this._ref)
      : super(const AsyncValue.data(null));

  final CompatibilityRepository _repo;
  final Ref _ref;

  Future<bool> generate(String partnerId) async {
    state = const AsyncValue.loading();
    final result = await _repo.generateReport(partnerId);
    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        _ref.invalidate(compatibilityReportProvider(partnerId));
        return true;
      },
      failure: (f) {
        state = AsyncValue.error(f.toString(), StackTrace.current);
        return false;
      },
    );
  }
}

final generateReportProvider = StateNotifierProvider.autoDispose
    .family<GenerateReportNotifier, AsyncValue<void>, String>((ref, partnerId) {
  return GenerateReportNotifier(
    ref.watch(compatibilityRepositoryProvider),
    ref,
  );
});
