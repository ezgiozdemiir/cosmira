import 'package:equatable/equatable.dart';

/// One planet's real, computed astrocartography lines (see the
/// `calculate-astrocartography-lines` edge function). `mcLon`/`icLon` are
/// single meridians (culminating/anti-culminating); `ac`/`dc` are polylines
/// of (latitude, longitude) points across the globe where the planet was
/// rising/setting at the birth moment.
class PlanetLine extends Equatable {
  final double mcLon;
  final double icLon;
  final List<(double, double)> ac;
  final List<(double, double)> dc;

  const PlanetLine({
    required this.mcLon,
    required this.icLon,
    required this.ac,
    required this.dc,
  });

  factory PlanetLine.fromJson(Map<String, dynamic> json) => PlanetLine(
        mcLon: (json['mc_lon'] as num).toDouble(),
        icLon: (json['ic_lon'] as num).toDouble(),
        ac: _parsePoints(json['ac'] as List),
        dc: _parsePoints(json['dc'] as List),
      );

  static List<(double, double)> _parsePoints(List raw) => raw
      .map((p) => ((p[0] as num).toDouble(), (p[1] as num).toDouble()))
      .toList();

  @override
  List<Object?> get props => [mcLon, icLon, ac.length, dc.length];
}

/// Real astrocartography lines for all 8 planets, computed from one
/// person's actual birth date/time/location.
class AstrocartographyLines extends Equatable {
  final Map<String, PlanetLine> planets;

  const AstrocartographyLines({required this.planets});

  factory AstrocartographyLines.fromJson(Map<String, dynamic> json) {
    final planetsJson = json['planets'] as Map<String, dynamic>;
    return AstrocartographyLines(
      planets: planetsJson.map(
        (key, value) => MapEntry(key, PlanetLine.fromJson(value as Map<String, dynamic>)),
      ),
    );
  }

  PlanetLine? forPlanet(String key) => planets[key];

  @override
  List<Object?> get props => [planets];
}
