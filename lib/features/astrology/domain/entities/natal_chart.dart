import 'package:equatable/equatable.dart';

class NatalChart extends Equatable {
  final String id;
  final String userId;
  final String sunSign;
  final double sunDegree;
  final String moonSign;
  final double moonDegree;
  final String risingSign;
  final double risingDegree;
  final Map<String, PlanetPosition> planets;
  final List<ChartAspect> aspects;
  final Map<String, String> houses;
  final DateTime calculatedAt;

  const NatalChart({
    required this.id,
    required this.userId,
    required this.sunSign,
    required this.sunDegree,
    required this.moonSign,
    required this.moonDegree,
    required this.risingSign,
    required this.risingDegree,
    required this.planets,
    required this.aspects,
    required this.houses,
    required this.calculatedAt,
  });

  @override
  List<Object?> get props => [id, userId];
}

class PlanetPosition extends Equatable {
  final String planet;
  final String sign;
  final double degree;
  final bool isRetrograde;

  const PlanetPosition({
    required this.planet,
    required this.sign,
    required this.degree,
    this.isRetrograde = false,
  });

  @override
  List<Object?> get props => [planet, sign, degree];
}

class ChartAspect extends Equatable {
  final String planet1;
  final String planet2;
  final String aspectType;
  final double orb;

  const ChartAspect({
    required this.planet1,
    required this.planet2,
    required this.aspectType,
    required this.orb,
  });

  @override
  List<Object?> get props => [planet1, planet2, aspectType];
}
