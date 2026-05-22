import '../../domain/entities/moon_phase.dart';

class MoonPhaseModel extends MoonPhase {
  const MoonPhaseModel({
    required super.id,
    required super.date,
    required super.phaseName,
    required super.illumination,
    required super.zodiacSign,
    required super.ritualTitle,
    required super.ritualDescription,
    required super.intentions,
    super.crystalRecommendation,
  });

  factory MoonPhaseModel.fromJson(Map<String, dynamic> json) {
    return MoonPhaseModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      phaseName: json['phase_name'] as String,
      illumination: (json['illumination'] as num).toDouble(),
      zodiacSign: json['zodiac_sign'] as String,
      ritualTitle: json['ritual_title'] as String? ?? '',
      ritualDescription: json['ritual_description'] as String? ?? '',
      intentions: (json['intentions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      crystalRecommendation: json['crystal_recommendation'] as String?,
    );
  }
}
