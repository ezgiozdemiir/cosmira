import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String? displayName;
  final String? avatarUrl;
  final DateTime? birthDate;
  final String? birthTime;
  final String? birthCity;
  final double? birthLat;
  final double? birthLng;
  final String? sunSign;
  final String? moonSign;
  final String? risingSign;
  final String subscriptionTier;
  final bool onboardingComplete;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    this.displayName,
    this.avatarUrl,
    this.birthDate,
    this.birthTime,
    this.birthCity,
    this.birthLat,
    this.birthLng,
    this.sunSign,
    this.moonSign,
    this.risingSign,
    this.subscriptionTier = 'free',
    this.onboardingComplete = false,
    required this.createdAt,
  });

  bool get isPremium => subscriptionTier != 'free';
  bool get hasBirthData => birthDate != null && birthCity != null;

  @override
  List<Object?> get props => [id, displayName, subscriptionTier, onboardingComplete];
}
