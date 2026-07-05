import 'dart:math' as math;

import 'astrocartography_lines.dart';

/// A real, named place used as the candidate pool for "Your Power Cities"
/// and the "Destiny Compass" — deliberately spans every continent/longitude
/// so any computed line has *something* reasonably close to match against.
class PowerCityCandidate {
  final String name;
  final String country;
  final double lat;
  final double lng;

  const PowerCityCandidate({
    required this.name,
    required this.country,
    required this.lat,
    required this.lng,
  });
}

const List<PowerCityCandidate> powerCityCandidates = [
  PowerCityCandidate(name: 'Athens', country: 'Greece', lat: 37.98, lng: 23.73),
  PowerCityCandidate(name: 'Lisbon', country: 'Portugal', lat: 38.72, lng: -9.14),
  PowerCityCandidate(name: 'Tokyo', country: 'Japan', lat: 35.68, lng: 139.69),
  PowerCityCandidate(name: 'Reykjavik', country: 'Iceland', lat: 64.15, lng: -21.94),
  PowerCityCandidate(name: 'Sydney', country: 'Australia', lat: -33.87, lng: 151.21),
  PowerCityCandidate(name: 'Denpasar', country: 'Indonesia', lat: -8.65, lng: 115.22),
  PowerCityCandidate(name: 'Marrakech', country: 'Morocco', lat: 31.63, lng: -7.99),
  PowerCityCandidate(name: 'Edinburgh', country: 'United Kingdom', lat: 55.95, lng: -3.19),
  PowerCityCandidate(name: 'New York', country: 'USA', lat: 40.71, lng: -74.01),
  PowerCityCandidate(name: 'Los Angeles', country: 'USA', lat: 34.05, lng: -118.24),
  PowerCityCandidate(name: 'Chicago', country: 'USA', lat: 41.88, lng: -87.63),
  PowerCityCandidate(name: 'Toronto', country: 'Canada', lat: 43.65, lng: -79.38),
  PowerCityCandidate(name: 'Vancouver', country: 'Canada', lat: 49.28, lng: -123.12),
  PowerCityCandidate(name: 'Mexico City', country: 'Mexico', lat: 19.43, lng: -99.13),
  PowerCityCandidate(name: 'Havana', country: 'Cuba', lat: 23.13, lng: -82.38),
  PowerCityCandidate(name: 'Bogotá', country: 'Colombia', lat: 4.71, lng: -74.07),
  PowerCityCandidate(name: 'Lima', country: 'Peru', lat: -12.05, lng: -77.04),
  PowerCityCandidate(name: 'Santiago', country: 'Chile', lat: -33.45, lng: -70.67),
  PowerCityCandidate(name: 'Buenos Aires', country: 'Argentina', lat: -34.60, lng: -58.38),
  PowerCityCandidate(name: 'Rio de Janeiro', country: 'Brazil', lat: -22.91, lng: -43.17),
  PowerCityCandidate(name: 'São Paulo', country: 'Brazil', lat: -23.55, lng: -46.63),
  PowerCityCandidate(name: 'London', country: 'United Kingdom', lat: 51.51, lng: -0.13),
  PowerCityCandidate(name: 'Dublin', country: 'Ireland', lat: 53.35, lng: -6.26),
  PowerCityCandidate(name: 'Paris', country: 'France', lat: 48.86, lng: 2.35),
  PowerCityCandidate(name: 'Berlin', country: 'Germany', lat: 52.52, lng: 13.40),
  PowerCityCandidate(name: 'Rome', country: 'Italy', lat: 41.90, lng: 12.50),
  PowerCityCandidate(name: 'Madrid', country: 'Spain', lat: 40.42, lng: -3.70),
  PowerCityCandidate(name: 'Amsterdam', country: 'Netherlands', lat: 52.37, lng: 4.90),
  PowerCityCandidate(name: 'Vienna', country: 'Austria', lat: 48.21, lng: 16.37),
  PowerCityCandidate(name: 'Prague', country: 'Czechia', lat: 50.08, lng: 14.44),
  PowerCityCandidate(name: 'Stockholm', country: 'Sweden', lat: 59.33, lng: 18.07),
  PowerCityCandidate(name: 'Oslo', country: 'Norway', lat: 59.91, lng: 10.75),
  PowerCityCandidate(name: 'Copenhagen', country: 'Denmark', lat: 55.68, lng: 12.57),
  PowerCityCandidate(name: 'Helsinki', country: 'Finland', lat: 60.17, lng: 24.94),
  PowerCityCandidate(name: 'Moscow', country: 'Russia', lat: 55.76, lng: 37.62),
  PowerCityCandidate(name: 'Istanbul', country: 'Turkey', lat: 41.01, lng: 28.95),
  PowerCityCandidate(name: 'Cairo', country: 'Egypt', lat: 30.04, lng: 31.24),
  PowerCityCandidate(name: 'Nairobi', country: 'Kenya', lat: -1.29, lng: 36.82),
  PowerCityCandidate(name: 'Cape Town', country: 'South Africa', lat: -33.92, lng: 18.42),
  PowerCityCandidate(name: 'Lagos', country: 'Nigeria', lat: 6.52, lng: 3.38),
  PowerCityCandidate(name: 'Casablanca', country: 'Morocco', lat: 33.57, lng: -7.59),
  PowerCityCandidate(name: 'Dubai', country: 'UAE', lat: 25.20, lng: 55.27),
  PowerCityCandidate(name: 'Riyadh', country: 'Saudi Arabia', lat: 24.71, lng: 46.68),
  PowerCityCandidate(name: 'Tel Aviv', country: 'Israel', lat: 32.08, lng: 34.78),
  PowerCityCandidate(name: 'Mumbai', country: 'India', lat: 19.08, lng: 72.88),
  PowerCityCandidate(name: 'Delhi', country: 'India', lat: 28.61, lng: 77.21),
  PowerCityCandidate(name: 'Bangkok', country: 'Thailand', lat: 13.76, lng: 100.50),
  PowerCityCandidate(name: 'Singapore', country: 'Singapore', lat: 1.35, lng: 103.82),
  PowerCityCandidate(name: 'Kuala Lumpur', country: 'Malaysia', lat: 3.14, lng: 101.69),
  PowerCityCandidate(name: 'Jakarta', country: 'Indonesia', lat: -6.21, lng: 106.85),
  PowerCityCandidate(name: 'Manila', country: 'Philippines', lat: 14.60, lng: 120.98),
  PowerCityCandidate(name: 'Hong Kong', country: 'China', lat: 22.32, lng: 114.17),
  PowerCityCandidate(name: 'Seoul', country: 'South Korea', lat: 37.57, lng: 126.98),
  PowerCityCandidate(name: 'Beijing', country: 'China', lat: 39.90, lng: 116.41),
  PowerCityCandidate(name: 'Shanghai', country: 'China', lat: 31.23, lng: 121.47),
  PowerCityCandidate(name: 'Taipei', country: 'Taiwan', lat: 25.03, lng: 121.57),
  PowerCityCandidate(name: 'Melbourne', country: 'Australia', lat: -37.81, lng: 144.96),
  PowerCityCandidate(name: 'Auckland', country: 'New Zealand', lat: -36.85, lng: 174.76),
  PowerCityCandidate(name: 'Honolulu', country: 'USA', lat: 21.31, lng: -157.86),
  PowerCityCandidate(name: 'Anchorage', country: 'USA', lat: 61.22, lng: -149.90),
];

/// Converts a longitude normalized to [0, 360) to the signed [-180, 180)
/// form — same convention used for map rendering in astrocartography_screen.
double signedLon(double lon) {
  var n = lon % 360;
  if (n < 0) n += 360;
  return n > 180 ? n - 360 : n;
}

/// Shortest angular distance between two longitudes, in degrees.
double lonDiff(double a, double b) {
  final d = (signedLon(a) - signedLon(b)).abs();
  return d > 180 ? 360 - d : d;
}

/// Standard haversine great-circle distance in km — used only to rank
/// candidates, not necessarily shown to the user.
double haversineKm(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371.0;
  final dLat = (lat2 - lat1) * math.pi / 180;
  final dLng = lonDiff(lng1, lng2) * math.pi / 180;
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1 * math.pi / 180) *
          math.cos(lat2 * math.pi / 180) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return r * c;
}

/// One line-type's worth of a [PlanetLine], for closest-city matching.
enum LineTypeKey { ac, dc, mc, ic }

class MatchedCity {
  final PowerCityCandidate city;
  final LineTypeKey lineType;
  final double distanceKm;

  const MatchedCity({
    required this.city,
    required this.lineType,
    required this.distanceKm,
  });
}

(double, double)? _nearestPointByLat(List<(double, double)> points, double targetLat) {
  if (points.isEmpty) return null;
  return points.reduce(
      (a, b) => (a.$1 - targetLat).abs() < (b.$1 - targetLat).abs() ? a : b);
}

/// Finds, among [candidates], the single real city closest to ANY of
/// [line]'s 4 line types (MC/IC meridians, or the nearest-latitude sample
/// of the AC/DC curves).
MatchedCity? closestCityForPlanet(PlanetLine line, List<PowerCityCandidate> candidates) {
  MatchedCity? best;

  void consider(PowerCityCandidate city, LineTypeKey type, double lineLat, double lineLng) {
    final d = haversineKm(city.lat, city.lng, lineLat, lineLng);
    if (best == null || d < best!.distanceKm) {
      best = MatchedCity(city: city, lineType: type, distanceKm: d);
    }
  }

  for (final city in candidates) {
    consider(city, LineTypeKey.mc, city.lat, line.mcLon);
    consider(city, LineTypeKey.ic, city.lat, line.icLon);

    final ac = _nearestPointByLat(line.ac, city.lat);
    if (ac != null) consider(city, LineTypeKey.ac, ac.$1, ac.$2);

    final dc = _nearestPointByLat(line.dc, city.lat);
    if (dc != null) consider(city, LineTypeKey.dc, dc.$1, dc.$2);
  }

  return best;
}

class PlanetCityMatch {
  final String planetKey;
  final MatchedCity match;
  const PlanetCityMatch({required this.planetKey, required this.match});
}

/// For each planet in [lines], finds its single closest real city (across
/// all 4 line types), then returns the top [count] planets ranked by
/// distance — one city per planet, mirroring the original static list's
/// one-city-per-planet variety, but now genuinely computed.
List<PlanetCityMatch> topCitiesFor(
  AstrocartographyLines lines, {
  int count = 8,
  List<PowerCityCandidate> candidates = powerCityCandidates,
}) {
  final matches = <PlanetCityMatch>[];
  for (final entry in lines.planets.entries) {
    final match = closestCityForPlanet(entry.value, candidates);
    if (match != null) {
      matches.add(PlanetCityMatch(planetKey: entry.key, match: match));
    }
  }
  matches.sort((a, b) => a.match.distanceKm.compareTo(b.match.distanceKm));
  return matches.take(count).toList();
}

/// Best real-city match among a themed subset of planets (see Destiny
/// Compass conventions: career → Sun/Saturn/Jupiter/Mars, love →
/// Venus/Moon, home → Moon/Venus) — used once per Destiny Compass card.
PlanetCityMatch? destinyMatchFor(
  AstrocartographyLines lines, {
  required List<String> planetKeys,
  List<PowerCityCandidate> candidates = powerCityCandidates,
}) {
  PlanetCityMatch? best;
  for (final key in planetKeys) {
    final line = lines.planets[key];
    if (line == null) continue;
    final match = closestCityForPlanet(line, candidates);
    if (match == null) continue;
    if (best == null || match.distanceKm < best.match.distanceKm) {
      best = PlanetCityMatch(planetKey: key, match: match);
    }
  }
  return best;
}

/// A real "paran" match: the point where two planets' lines pass closest to
/// one another (a true crossing when the gap reaches ~0°, otherwise the
/// nearest approach — same tolerant convention already used for city
/// matching), resolved to the nearest real candidate city.
class ParanMatch {
  final MatchedCity city;
  final LineTypeKey lineTypeA;
  final LineTypeKey lineTypeB;

  const ParanMatch({
    required this.city,
    required this.lineTypeA,
    required this.lineTypeB,
  });
}

const _verticalLineTypes = {LineTypeKey.mc, LineTypeKey.ic};

List<(double, double)> _curveFor(
    PlanetLine line, LineTypeKey type, List<double> latGrid) {
  switch (type) {
    case LineTypeKey.ac:
      return line.ac;
    case LineTypeKey.dc:
      return line.dc;
    case LineTypeKey.mc:
      return latGrid.map((lat) => (lat, line.mcLon)).toList();
    case LineTypeKey.ic:
      return latGrid.map((lat) => (lat, line.icLon)).toList();
  }
}

/// Closest-approach point between two lat-indexed curves (same grid) —
/// returns (lat, lon, lonDiff at that lat) for the smallest gap found.
(double, double, double)? _closestApproach(
    List<(double, double)> curveA, List<(double, double)> curveB) {
  final n = curveA.length < curveB.length ? curveA.length : curveB.length;
  if (n == 0) return null;
  var bestDiff = double.infinity;
  var bestLat = 0.0;
  var bestLon = 0.0;
  for (var i = 0; i < n; i++) {
    final diff = lonDiff(curveA[i].$2, curveB[i].$2);
    if (diff < bestDiff) {
      bestDiff = diff;
      bestLat = curveA[i].$1;
      bestLon = curveA[i].$2;
    }
  }
  return (bestLat, bestLon, bestDiff);
}

/// Finds where [planetKeyA]'s and [planetKeyB]'s lines pass closest to each
/// other (across every AC/DC/MC/IC combination, skipping the two constant
/// meridians against each other since parallel verticals never converge),
/// then resolves that point to the nearest real candidate city.
ParanMatch? paranMatchFor(
  AstrocartographyLines lines, {
  required String planetKeyA,
  required String planetKeyB,
  List<PowerCityCandidate> candidates = powerCityCandidates,
}) {
  final a = lines.planets[planetKeyA];
  final b = lines.planets[planetKeyB];
  if (a == null || b == null) return null;

  final latGrid =
      (a.ac.isNotEmpty ? a.ac : b.ac).map((p) => p.$1).toList();
  if (latGrid.isEmpty) return null;

  var bestDiff = double.infinity;
  var bestLat = 0.0;
  var bestLon = 0.0;
  LineTypeKey? bestTypeA;
  LineTypeKey? bestTypeB;

  for (final typeA in LineTypeKey.values) {
    for (final typeB in LineTypeKey.values) {
      if (_verticalLineTypes.contains(typeA) &&
          _verticalLineTypes.contains(typeB)) {
        continue;
      }
      final approach = _closestApproach(
        _curveFor(a, typeA, latGrid),
        _curveFor(b, typeB, latGrid),
      );
      if (approach == null) continue;
      if (approach.$3 < bestDiff) {
        bestDiff = approach.$3;
        bestLat = approach.$1;
        bestLon = approach.$2;
        bestTypeA = typeA;
        bestTypeB = typeB;
      }
    }
  }

  if (bestTypeA == null || bestTypeB == null) return null;

  PowerCityCandidate? nearestCity;
  var nearestDist = double.infinity;
  for (final c in candidates) {
    final d = haversineKm(c.lat, c.lng, bestLat, bestLon);
    if (d < nearestDist) {
      nearestDist = d;
      nearestCity = c;
    }
  }
  if (nearestCity == null) return null;

  return ParanMatch(
    city: MatchedCity(
        city: nearestCity, lineType: bestTypeA, distanceKm: nearestDist),
    lineTypeA: bestTypeA,
    lineTypeB: bestTypeB,
  );
}
