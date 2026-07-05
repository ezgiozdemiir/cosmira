const _signs = [
  'aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
  'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces',
];

/// Sign-based aspect types — computed from whole zodiac signs, not exact
/// degrees, since `profiles` only stores each placement's sign (no stored
/// birth-chart longitudes exist anywhere in this app today). This is a
/// standard, real astrological technique (not an approximation invented for
/// this feature) for when exact degrees aren't available.
enum NatalAspectType { conjunction, semisextile, sextile, square, trine, quincunx, opposition }

const _aspectBySignDistance = {
  0: NatalAspectType.conjunction,
  1: NatalAspectType.semisextile,
  2: NatalAspectType.sextile,
  3: NatalAspectType.square,
  4: NatalAspectType.trine,
  5: NatalAspectType.quincunx,
  6: NatalAspectType.opposition,
};

/// Only "major" aspects are surfaced as the day's headline aspect — minor
/// ones (semisextile/quincunx) are real but too weak to be worth calling out.
const _majorAspects = {
  NatalAspectType.conjunction,
  NatalAspectType.sextile,
  NatalAspectType.square,
  NatalAspectType.trine,
  NatalAspectType.opposition,
};

class NatalAspect {
  final String natalPoint; // 'sun' | 'moon' | 'rising'
  final NatalAspectType type;
  const NatalAspect({required this.natalPoint, required this.type});
}

class MoonTransit {
  final int house; // 1-12, whole-sign house relative to the Rising sign
  final String moonSign;
  final NatalAspect? aspect;
  const MoonTransit({required this.house, required this.moonSign, this.aspect});
}

class MoonTransitCalculator {
  static int _signIndex(String sign) => _signs.indexOf(sign.toLowerCase());

  static int? houseForTransitSign(String transitSign, String risingSign) {
    final t = _signIndex(transitSign);
    final r = _signIndex(risingSign);
    if (t == -1 || r == -1) return null;
    return ((t - r) % 12 + 12) % 12 + 1;
  }

  static NatalAspectType? _aspectType(String signA, String signB) {
    final a = _signIndex(signA);
    final b = _signIndex(signB);
    if (a == -1 || b == -1) return null;
    var dist = (a - b).abs() % 12;
    if (dist > 6) dist = 12 - dist;
    return _aspectBySignDistance[dist];
  }

  /// Computes today's transiting-Moon impact on the user's real natal Sun,
  /// Moon, and Rising signs. Sun is checked first, so a tie between two
  /// equally "major" aspects favors the Sun as the most significant point.
  static MoonTransit? compute({
    required String transitMoonSign,
    required String? sunSign,
    required String? moonSign,
    required String? risingSign,
  }) {
    if (risingSign == null) return null;
    final house = houseForTransitSign(transitMoonSign, risingSign);
    if (house == null) return null;

    NatalAspect? best;
    for (final entry in <String, String?>{
      'sun': sunSign,
      'moon': moonSign,
      'rising': risingSign,
    }.entries) {
      final natalSign = entry.value;
      if (natalSign == null) continue;
      final type = _aspectType(transitMoonSign, natalSign);
      if (type == null || !_majorAspects.contains(type)) continue;
      best ??= NatalAspect(natalPoint: entry.key, type: type);
    }

    return MoonTransit(house: house, moonSign: transitMoonSign, aspect: best);
  }
}
