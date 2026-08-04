import 'package:equatable/equatable.dart';

class UserSubscription extends Equatable {
  final String id;
  final String userId;
  final String tier;
  final String platform;
  final String? revenuecatId;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  const UserSubscription({
    required this.id,
    required this.userId,
    required this.tier,
    required this.platform,
    this.revenuecatId,
    required this.startDate,
    this.endDate,
    required this.isActive,
  });

  bool get isPremium => tier != 'free' && isActive;

  @override
  List<Object?> get props => [id, userId, tier, isActive];
}

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double monthlyPrice;
  final double? yearlyPrice;
  final List<String> features;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    this.yearlyPrice,
    required this.features,
  });

  // `features` holds translation keys (rendered via .tr() at the paywall),
  // not display text.
  static const free = SubscriptionPlan(
    id: 'free',
    name: 'Celestial',
    description: 'Start your cosmic journey',
    monthlyPrice: 0,
    features: [
      'paywall_feature_daily_horoscope',
      'paywall_feature_breathwork_daily',
      'paywall_feature_moon_calendar',
      'paywall_feature_compat_partners_2',
      'paywall_feature_natal_basic',
      'paywall_feature_birth_changes_2',
    ],
  );

  static const premium = SubscriptionPlan(
    id: 'premium',
    name: 'Astral',
    description: 'Unlock the full cosmos',
    monthlyPrice: 120,
    yearlyPrice: 999,
    features: [
      'paywall_feature_everything_celestial',
      'paywall_feature_breathwork_unlimited',
      'paywall_feature_compat_partners_10',
      'paywall_feature_compat_deep',
      'paywall_feature_yearly_destiny',
      'paywall_feature_astrocartography',
      'paywall_feature_priority_ai',
      'paywall_feature_birth_changes_5',
    ],
  );
}
