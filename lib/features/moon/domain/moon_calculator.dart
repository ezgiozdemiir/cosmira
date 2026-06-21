import 'dart:math' as math;

import 'entities/moon_phase.dart';

/// Computes moon phases, illumination, and zodiac position locally.
/// No network or DB required — all astronomy is derived from reference epochs.
class MoonCalculator {
  // Reference new moon: 6 Jan 2000, 18:14 UTC
  static final _newMoonRef = DateTime.utc(2000, 1, 6, 18, 14);
  static const _synodic = 29.530588853; // mean synodic period in days

  // Moon's mean ecliptic longitude at J2000.0 (1 Jan 2000, 12:00 UTC)
  static final _j2000 = DateTime.utc(2000, 1, 1, 12);
  static const _moonLon0 = 218.3165; // degrees
  static const _moonLonRate = 13.17639648; // degrees per day

  /// Moon age in days since last new moon (0 – 29.53).
  static double ageForDate(DateTime date) {
    final days = date.difference(_newMoonRef).inSeconds / 86400.0;
    final age = days % _synodic;
    return age < 0 ? age + _synodic : age;
  }

  /// Illuminated fraction 0.0 (new) → 1.0 (full).
  static double illuminationForAge(double age) {
    final phi = (age / _synodic) * 2 * math.pi;
    return (1 - math.cos(phi)) / 2;
  }

  static String phaseNameForAge(double age) {
    final f = age / _synodic;
    if (f < 0.033 || f > 0.967) return 'new_moon';
    if (f < 0.233) return 'waxing_crescent';
    if (f < 0.283) return 'first_quarter';
    if (f < 0.467) return 'waxing_gibbous';
    if (f < 0.533) return 'full_moon';
    if (f < 0.717) return 'waning_gibbous';
    if (f < 0.767) return 'last_quarter';
    return 'waning_crescent';
  }

  static String zodiacSignForDate(DateTime date) {
    final days = date.difference(_j2000).inSeconds / 86400.0;
    var lon = (_moonLon0 + _moonLonRate * days) % 360;
    if (lon < 0) lon += 360;
    const signs = [
      'aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
      'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces',
    ];
    return signs[(lon / 30).floor() % 12];
  }

  /// Build a full [MoonPhase] for any given date.
  static MoonPhase forDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final age = ageForDate(day);
    final name = phaseNameForAge(age);
    final illum = illuminationForAge(age);
    final sign = zodiacSignForDate(day);
    final ritual = _rituals[name]!;
    return MoonPhase(
      id: '${day.year}-${day.month}-${day.day}',
      date: day,
      phaseName: name,
      illumination: illum,
      zodiacSign: sign,
      ritualTitle: ritual['title']! as String,
      ritualDescription: ritual['description']! as String,
      intentions: List<String>.from(ritual['intentions']! as List),
      crystalRecommendation: ritual['crystal']! as String,
    );
  }

  /// One [MoonPhase] per calendar day for the given month.
  static List<MoonPhase> forMonth(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return List.generate(
      daysInMonth,
      (i) => forDate(DateTime(year, month, i + 1)),
    );
  }

  static const _rituals = <String, Map<String, Object>>{
    'new_moon': {
      'title': 'moon_ritual_new_moon_title',
      'description': 'moon_ritual_new_moon_desc',
      'intentions': ['moon_int_new_beginnings', 'moon_int_manifestation', 'moon_int_inner_clarity', 'moon_int_renewal'],
      'crystal': 'moon_crystal_new_moon',
    },
    'waxing_crescent': {
      'title': 'moon_ritual_waxing_crescent_title',
      'description': 'moon_ritual_waxing_crescent_desc',
      'intentions': ['moon_int_growth', 'moon_int_courage', 'moon_int_momentum', 'moon_int_trust'],
      'crystal': 'moon_crystal_waxing_crescent',
    },
    'first_quarter': {
      'title': 'moon_ritual_first_quarter_title',
      'description': 'moon_ritual_first_quarter_desc',
      'intentions': ['moon_int_decision', 'moon_int_commitment', 'moon_int_strength', 'moon_int_perseverance'],
      'crystal': 'moon_crystal_first_quarter',
    },
    'waxing_gibbous': {
      'title': 'moon_ritual_waxing_gibbous_title',
      'description': 'moon_ritual_waxing_gibbous_desc',
      'intentions': ['moon_int_refinement', 'moon_int_patience', 'moon_int_alignment', 'moon_int_devotion'],
      'crystal': 'moon_crystal_waxing_gibbous',
    },
    'full_moon': {
      'title': 'moon_ritual_full_moon_title',
      'description': 'moon_ritual_full_moon_desc',
      'intentions': ['moon_int_release', 'moon_int_celebration', 'moon_int_gratitude', 'moon_int_illumination'],
      'crystal': 'moon_crystal_full_moon',
    },
    'waning_gibbous': {
      'title': 'moon_ritual_waning_gibbous_title',
      'description': 'moon_ritual_waning_gibbous_desc',
      'intentions': ['moon_int_gratitude', 'moon_int_generosity', 'moon_int_teaching', 'moon_int_abundance'],
      'crystal': 'moon_crystal_waning_gibbous',
    },
    'last_quarter': {
      'title': 'moon_ritual_last_quarter_title',
      'description': 'moon_ritual_last_quarter_desc',
      'intentions': ['moon_int_forgiveness', 'moon_int_release', 'moon_int_healing', 'moon_int_surrender'],
      'crystal': 'moon_crystal_last_quarter',
    },
    'waning_crescent': {
      'title': 'moon_ritual_waning_crescent_title',
      'description': 'moon_ritual_waning_crescent_desc',
      'intentions': ['moon_int_rest', 'moon_int_reflection', 'moon_int_dreams', 'moon_int_surrender'],
      'crystal': 'moon_crystal_waning_crescent',
    },
  };
}
