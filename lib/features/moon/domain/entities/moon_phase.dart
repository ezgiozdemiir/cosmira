import 'package:equatable/equatable.dart';

class MoonPhase extends Equatable {
  final String id;
  final DateTime date;
  final String phaseName;
  final double illumination;
  final String zodiacSign;
  final String ritualTitle;
  final String ritualDescription;
  final List<String> intentions;
  final String? crystalRecommendation;

  const MoonPhase({
    required this.id,
    required this.date,
    required this.phaseName,
    required this.illumination,
    required this.zodiacSign,
    required this.ritualTitle,
    required this.ritualDescription,
    required this.intentions,
    this.crystalRecommendation,
  });

  bool get isNewMoon => phaseName == 'new_moon';
  bool get isFullMoon => phaseName == 'full_moon';

  String get phaseEmoji {
    switch (phaseName) {
      case 'new_moon':
        return '🌑';
      case 'waxing_crescent':
        return '🌒';
      case 'first_quarter':
        return '🌓';
      case 'waxing_gibbous':
        return '🌔';
      case 'full_moon':
        return '🌕';
      case 'waning_gibbous':
        return '🌖';
      case 'last_quarter':
        return '🌗';
      case 'waning_crescent':
        return '🌘';
      default:
        return '🌙';
    }
  }

  @override
  List<Object?> get props => [id, date, phaseName];
}
