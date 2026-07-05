import 'package:equatable/equatable.dart';

/// Allowed values for [UserProfile.gender], matching the `gender_type` enum
/// in the `profiles` table.
abstract final class Gender {
  static const female = 'female';
  static const male = 'male';
  static const preferNotToSay = 'prefer_not_to_say';

  static const values = [female, male, preferNotToSay];

  static String label(String value) => switch (value) {
        female => 'Female',
        male => 'Male',
        _ => 'Prefer not to say',
      };
}

class UserProfile extends Equatable {
  final String id;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? avatarUrl;
  final DateTime? birthDate;
  final String? birthTime;
  final String? birthCity;
  final double? birthLat;
  final double? birthLng;
  final String? sunSign;
  final String? moonSign;
  final String? risingSign;
  final String? mcSign;
  final String subscriptionTier;
  final bool onboardingComplete;
  final int birthDataVersion;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    this.displayName,
    this.firstName,
    this.lastName,
    this.gender,
    this.avatarUrl,
    this.birthDate,
    this.birthTime,
    this.birthCity,
    this.birthLat,
    this.birthLng,
    this.sunSign,
    this.moonSign,
    this.risingSign,
    this.mcSign,
    this.subscriptionTier = 'free',
    this.onboardingComplete = false,
    this.birthDataVersion = 0,
    required this.createdAt,
  });

  bool get isPremium => subscriptionTier != 'free';
  bool get hasBirthData => birthDate != null && birthTime != null && birthCity != null;
  String get fullName => [firstName, lastName].whereType<String>().join(' ').trim();

  /// Lifetime cap on birth-data edits: 2 for free accounts, 5 for pro.
  int get birthDataEditLimit => isPremium ? 5 : 2;
  int get birthDataEditsRemaining => (birthDataEditLimit - birthDataVersion).clamp(0, birthDataEditLimit);

  @override
  List<Object?> get props => [id, firstName, lastName, subscriptionTier, onboardingComplete];
}
