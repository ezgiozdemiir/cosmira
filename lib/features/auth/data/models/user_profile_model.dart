import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    super.displayName,
    super.avatarUrl,
    super.birthDate,
    super.birthTime,
    super.birthCity,
    super.birthLat,
    super.birthLng,
    super.sunSign,
    super.moonSign,
    super.risingSign,
    super.subscriptionTier,
    super.onboardingComplete,
    required super.createdAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      birthTime: json['birth_time'] as String?,
      birthCity: json['birth_city'] as String?,
      birthLat: (json['birth_lat'] as num?)?.toDouble(),
      birthLng: (json['birth_lng'] as num?)?.toDouble(),
      sunSign: json['sun_sign'] as String?,
      moonSign: json['moon_sign'] as String?,
      risingSign: json['rising_sign'] as String?,
      subscriptionTier: json['subscription_tier'] as String? ?? 'free',
      onboardingComplete: json['onboarding_complete'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'birth_date': birthDate?.toIso8601String().split('T').first,
        'birth_time': birthTime,
        'birth_city': birthCity,
        'birth_lat': birthLat,
        'birth_lng': birthLng,
        'sun_sign': sunSign,
        'moon_sign': moonSign,
        'rising_sign': risingSign,
        'subscription_tier': subscriptionTier,
        'onboarding_complete': onboardingComplete,
      };
}
