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
  final int overallScore;
  final int emotionalScore;
  final int intellectualScore;
  final int physicalScore;
  final int spiritualScore;
  final String summary;
  final Map<String, dynamic>? deepAnalysis;
  final bool isPremium;
  final DateTime createdAt;

  const CompatibilityReport({
    required this.id,
    required this.userId,
    required this.partnerId,
    required this.overallScore,
    required this.emotionalScore,
    required this.intellectualScore,
    required this.physicalScore,
    required this.spiritualScore,
    required this.summary,
    this.deepAnalysis,
    this.isPremium = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, partnerId];
}
