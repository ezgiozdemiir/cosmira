import 'package:equatable/equatable.dart';

class CompatibilityPartner extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? avatarUrl;
  final DateTime birthDate;
  final String? birthTime;
  final String? birthCity;
  final double? birthLat;
  final double? birthLng;
  final String sunSign;
  final String? moonSign;
  final String? risingSign;
  final String relationship;
  final DateTime createdAt;

  const CompatibilityPartner({
    required this.id,
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.birthDate,
    this.birthTime,
    this.birthCity,
    this.birthLat,
    this.birthLng,
    required this.sunSign,
    this.moonSign,
    this.risingSign,
    required this.relationship,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, name];
}

class CompatibilityReport extends Equatable {
  final String id;
  final String userId;
  final String partnerId;
  final double overallScore;
  final double emotionalAlignment;
  final double communicationScore;
  final double karmicBond;
  final double intimacyEnergy;
  final double soulmateProbability;
  final double longTermScore;
  final double energeticBalance;
  final Map<String, dynamic> aiAnalysis;
  final bool isDeepScan;
  final DateTime createdAt;

  const CompatibilityReport({
    required this.id,
    required this.userId,
    required this.partnerId,
    required this.overallScore,
    required this.emotionalAlignment,
    required this.communicationScore,
    required this.karmicBond,
    required this.intimacyEnergy,
    required this.soulmateProbability,
    required this.longTermScore,
    required this.energeticBalance,
    required this.aiAnalysis,
    this.isDeepScan = false,
    required this.createdAt,
  });

  String? get summary => aiAnalysis['summary'] as String?;
  String? get emotionalInsight => aiAnalysis['emotional'] as String?;
  String? get communicationInsight => aiAnalysis['communication'] as String?;
  String? get karmicInsight => aiAnalysis['karmic'] as String?;
  String? get intimacyInsight => aiAnalysis['intimacy'] as String?;
  String? get longTermInsight => aiAnalysis['long_term'] as String?;
  String? get cosmicAdvice => aiAnalysis['advice'] as String?;
  List<String> get conflicts =>
      (aiAnalysis['conflicts'] as List?)?.cast<String>() ?? [];
  List<String> get strengths =>
      (aiAnalysis['strengths'] as List?)?.cast<String>() ?? [];

  @override
  List<Object?> get props => [id, userId, partnerId];
}
