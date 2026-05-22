import '../../domain/entities/natal_chart.dart';

class NatalChartModel extends NatalChart {
  const NatalChartModel({
    required super.id,
    required super.userId,
    required super.sunSign,
    required super.sunDegree,
    required super.moonSign,
    required super.moonDegree,
    required super.risingSign,
    required super.risingDegree,
    required super.planets,
    required super.aspects,
    required super.houses,
    required super.calculatedAt,
  });

  factory NatalChartModel.fromJson(Map<String, dynamic> json) {
    final planetData = json['planet_positions'] as Map<String, dynamic>? ?? {};
    final planets = planetData.map((key, value) {
      final v = value as Map<String, dynamic>;
      return MapEntry(
        key,
        PlanetPosition(
          planet: key,
          sign: v['sign'] as String,
          degree: (v['degree'] as num).toDouble(),
          isRetrograde: v['is_retrograde'] as bool? ?? false,
        ),
      );
    });

    final aspectData = json['aspects'] as List<dynamic>? ?? [];
    final aspects = aspectData.map((a) {
      final m = a as Map<String, dynamic>;
      return ChartAspect(
        planet1: m['planet1'] as String,
        planet2: m['planet2'] as String,
        aspectType: m['aspect_type'] as String,
        orb: (m['orb'] as num).toDouble(),
      );
    }).toList();

    final houseData = json['houses'] as Map<String, dynamic>? ?? {};
    final houses = houseData.map((k, v) => MapEntry(k, v.toString()));

    return NatalChartModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      sunSign: json['sun_sign'] as String,
      sunDegree: (json['sun_degree'] as num).toDouble(),
      moonSign: json['moon_sign'] as String,
      moonDegree: (json['moon_degree'] as num).toDouble(),
      risingSign: json['rising_sign'] as String,
      risingDegree: (json['rising_degree'] as num).toDouble(),
      planets: planets,
      aspects: aspects,
      houses: houses,
      calculatedAt: DateTime.parse(json['calculated_at'] as String),
    );
  }
}
