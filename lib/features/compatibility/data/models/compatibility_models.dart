import '../../domain/entities/compatibility_partner.dart';

class CompatibilityPartnerModel extends CompatibilityPartner {
  const CompatibilityPartnerModel({
    required super.id,
    required super.userId,
    required super.name,
    super.avatarUrl,
    required super.birthDate,
    super.birthTime,
    super.birthCity,
    super.birthLat,
    super.birthLng,
    required super.sunSign,
    super.moonSign,
    super.risingSign,
    required super.relationship,
    required super.createdAt,
  });

  factory CompatibilityPartnerModel.fromJson(Map<String, dynamic> json) {
    return CompatibilityPartnerModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      birthDate: DateTime.parse(json['birth_date'] as String),
      birthTime: json['birth_time'] as String?,
      birthCity: json['birth_city'] as String?,
      birthLat: (json['birth_lat'] as num?)?.toDouble(),
      birthLng: (json['birth_lng'] as num?)?.toDouble(),
      sunSign: json['sun_sign'] as String,
      moonSign: json['moon_sign'] as String?,
      risingSign: json['rising_sign'] as String?,
      relationship: json['relationship'] as String? ?? 'romantic',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class CompatibilityReportModel extends CompatibilityReport {
  const CompatibilityReportModel({
    required super.id,
    required super.userId,
    required super.partnerId,
    required super.overallScore,
    required super.emotionalAlignment,
    required super.communicationScore,
    required super.karmicBond,
    required super.intimacyEnergy,
    required super.soulmateProbability,
    required super.longTermScore,
    required super.energeticBalance,
    required super.aiAnalysis,
    super.isDeepScan,
    required super.createdAt,
  });

  factory CompatibilityReportModel.fromJson(Map<String, dynamic> json) {
    double toDouble(String key) => (json[key] as num?)?.toDouble() ?? 0.0;
    return CompatibilityReportModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      partnerId: json['partner_id'] as String,
      overallScore: toDouble('overall_score'),
      emotionalAlignment: toDouble('emotional_alignment'),
      communicationScore: toDouble('communication_score'),
      karmicBond: toDouble('karmic_bond'),
      intimacyEnergy: toDouble('intimacy_energy'),
      soulmateProbability: toDouble('soulmate_probability'),
      longTermScore: toDouble('long_term_score'),
      energeticBalance: toDouble('energetic_balance'),
      aiAnalysis: (json['ai_analysis'] as Map<String, dynamic>?) ?? {},
      isDeepScan: json['is_deep_scan'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
