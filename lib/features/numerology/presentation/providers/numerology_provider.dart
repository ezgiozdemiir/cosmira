import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../domain/numerology_calculator.dart';

// ── User analysis ────────────────────────────────────────────────────────────

final userNumerologyProvider = Provider<NumerologyResult?>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  if (profile?.birthDate == null) return null;
  final name =
      '${profile!.firstName ?? ''} ${profile.lastName ?? ''}'.trim();
  return NumerologyCalculator.calculate(
    name: name,
    birthDate: profile.birthDate!,
  );
});

// ── Family member ─────────────────────────────────────────────────────────────

class FamilyMember {
  final String name;
  final DateTime? birthDate;

  const FamilyMember({required this.name, this.birthDate});

  int? get lifePathNumber => birthDate != null
      ? NumerologyCalculator.calculateLifePath(birthDate!)
      : null;

  int get expressionNumber =>
      NumerologyCalculator.calculateExpression(name);

  NumerologyResult? get fullResult => birthDate != null
      ? NumerologyCalculator.calculate(name: name, birthDate: birthDate!)
      : null;
}

// ── Spouse ────────────────────────────────────────────────────────────────────

final spouseProvider = StateProvider<FamilyMember?>((ref) => null);

// ── Children ──────────────────────────────────────────────────────────────────

final childrenProvider =
    StateProvider<List<FamilyMember>>((ref) => const []);

// ── Couple number ─────────────────────────────────────────────────────────────

final coupleNumberProvider = Provider<int?>((ref) {
  final user = ref.watch(userNumerologyProvider);
  final spouse = ref.watch(spouseProvider);
  final spouseLp = spouse?.lifePathNumber;
  if (user == null || spouseLp == null) return null;
  return NumerologyCalculator.reduce(user.lifePathNumber + spouseLp);
});

// ── Family number (all members combined) ──────────────────────────────────────

final familyNumberProvider = Provider<int?>((ref) {
  final user = ref.watch(userNumerologyProvider);
  if (user == null) return null;
  int sum = user.lifePathNumber;
  final spouse = ref.watch(spouseProvider);
  if (spouse?.lifePathNumber != null) sum += spouse!.lifePathNumber!;
  for (final child in ref.watch(childrenProvider)) {
    final lp = child.lifePathNumber;
    if (lp != null) sum += lp;
  }
  return NumerologyCalculator.reduce(sum);
});
