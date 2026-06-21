import 'package:easy_localization/easy_localization.dart';

extension StringX on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get zodiacName {
    if (isEmpty) return this;
    return 'sign_${toLowerCase()}'.tr();
  }

  String get zodiacEmoji {
    const emojis = {
      'aries': '♈',
      'taurus': '♉',
      'gemini': '♊',
      'cancer': '♋',
      'leo': '♌',
      'virgo': '♍',
      'libra': '♎',
      'scorpio': '♏',
      'sagittarius': '♐',
      'capricorn': '♑',
      'aquarius': '♒',
      'pisces': '♓',
    };
    return emojis[toLowerCase()] ?? '';
  }
}
