import 'package:equatable/equatable.dart';

class BirthMap extends Equatable {
  final String id;
  final String userId;
  final Map<String, dynamic> content;
  final DateTime createdAt;

  const BirthMap({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory BirthMap.fromJson(Map<String, dynamic> json) => BirthMap(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        content: json['content'] as Map<String, dynamic>,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  String? get cosmicFingerprint => content['cosmic_fingerprint'] as String?;
  String? get cosmicWisdom => content['cosmic_wisdom'] as String?;

  Map<String, dynamic>? get personality =>
      content['personality'] as Map<String, dynamic>?;

  Map<String, dynamic>? get lifePurpose =>
      content['life_purpose'] as Map<String, dynamic>?;

  Map<String, dynamic>? get loveAndRelationships =>
      content['love_and_relationships'] as Map<String, dynamic>?;

  Map<String, dynamic>? get careerAndDestiny =>
      content['career_and_destiny'] as Map<String, dynamic>?;

  Map<String, dynamic>? get strengthsAndChallenges =>
      content['strengths_and_challenges'] as Map<String, dynamic>?;

  Map<String, dynamic>? get cosmicTiming =>
      content['cosmic_timing'] as Map<String, dynamic>?;

  List<Map<String, dynamic>> get yearPredictions {
    final years = cosmicTiming?['year_predictions'] as List?;
    return years?.cast<Map<String, dynamic>>() ?? [];
  }

  List<String> _strings(Map<String, dynamic>? section, String key) {
    final list = section?[key] as List?;
    return list?.cast<String>() ?? [];
  }

  List<String> get lightSide => _strings(personality, 'light_side');
  List<String> get shadowSide => _strings(personality, 'shadow_side');
  List<String> get karmicLessons => _strings(lifePurpose, 'karmic_lessons');
  List<String> get naturalTalents => _strings(careerAndDestiny, 'natural_talents');
  List<String> get idealPaths => _strings(careerAndDestiny, 'ideal_paths');
  List<String> get superpowers => _strings(strengthsAndChallenges, 'superpowers');
  List<String> get growthEdges => _strings(strengthsAndChallenges, 'growth_edges');

  @override
  List<Object?> get props => [id, userId];
}
