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

  static const free = SubscriptionPlan(
    id: 'free',
    name: 'Celestial',
    description: 'Start your cosmic journey',
    monthlyPrice: 0,
    features: [
      'Daily horoscope',
      '1 breathwork session/day',
      'Moon calendar',
      '2 compatibility partners',
      'Basic natal chart',
    ],
  );

  static const premium = SubscriptionPlan(
    id: 'premium',
    name: 'Astral',
    description: 'Unlock the full cosmos',
    monthlyPrice: 9.99,
    yearlyPrice: 59.99,
    features: [
      'Everything in Celestial',
      'Unlimited breathwork',
      '10 compatibility partners',
      'Deep compatibility reports',
      'Yearly destiny report',
      'Astrocartography',
      'No ads',
      '100 bonus Stardust/month',
      'Priority AI insights',
    ],
  );
}
