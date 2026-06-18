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
      'title': 'Plant Seeds of Intention',
      'description':
          'The New Moon opens a portal of infinite possibility. Sit in stillness, light a candle, and write your deepest desires on paper. The cosmos is ready to receive your call.',
      'intentions': ['New beginnings', 'Manifestation', 'Inner clarity', 'Renewal'],
      'crystal': 'Black Tourmaline & Labradorite',
    },
    'waxing_crescent': {
      'title': 'Nurture Your Vision',
      'description':
          'Your seeds are planted. Take inspired action and tend to your intentions daily. Every small, aligned step moves you closer to the life you are calling in.',
      'intentions': ['Growth', 'Courage', 'Momentum', 'Trust'],
      'crystal': 'Carnelian & Green Aventurine',
    },
    'first_quarter': {
      'title': 'Push Through Resistance',
      'description':
          'The First Quarter brings challenges that test your commitment. This friction is your teacher. Recommit to your vision and take one bold, decisive action today.',
      'intentions': ['Decision', 'Commitment', 'Strength', 'Perseverance'],
      'crystal': "Tiger's Eye & Citrine",
    },
    'waxing_gibbous': {
      'title': 'Refine & Align',
      'description':
          'You are almost there. Review your progress, release what is not working, and fine-tune your approach. Patience now is the most powerful force in your arsenal.',
      'intentions': ['Refinement', 'Patience', 'Alignment', 'Devotion'],
      'crystal': 'Lapis Lazuli & Clear Quartz',
    },
    'full_moon': {
      'title': 'Release & Illuminate',
      'description':
          'Under the Full Moon\'s radiant light, all is revealed. Write what you are ready to release and burn or bury the paper. Celebrate how far you have come — you are the cosmos.',
      'intentions': ['Release', 'Celebration', 'Gratitude', 'Illumination'],
      'crystal': 'Selenite & Moonstone',
    },
    'waning_gibbous': {
      'title': 'Share Your Wisdom',
      'description':
          'Having received the full light of manifestation, it is time to give. Share your gifts, teach what you know, and extend gratitude for the abundance flowing through your life.',
      'intentions': ['Gratitude', 'Generosity', 'Teaching', 'Abundance'],
      'crystal': 'Amethyst & Kyanite',
    },
    'last_quarter': {
      'title': 'Let Go & Forgive',
      'description':
          'The Last Quarter calls for sacred release. Forgive yourself and others without condition. Let go of the stories, patterns, and beliefs that dim your light.',
      'intentions': ['Forgiveness', 'Release', 'Healing', 'Surrender'],
      'crystal': 'Obsidian & Rose Quartz',
    },
    'waning_crescent': {
      'title': 'Rest & Dream',
      'description':
          'You have done the deep work. Now rest, dream vividly, and allow the universe to prepare the next cycle. Trust the sacred timing of all things unfolding for you.',
      'intentions': ['Rest', 'Reflection', 'Dreams', 'Surrender'],
      'crystal': 'Lepidolite & Celestite',
    },
  };
}
