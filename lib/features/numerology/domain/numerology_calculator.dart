class NumerologyResult {
  final String name;
  final DateTime birthDate;
  final int lifePathNumber;
  final int expressionNumber;
  final int soulUrgeNumber;
  final int personalityNumber;
  final int birthdayNumber;

  const NumerologyResult({
    required this.name,
    required this.birthDate,
    required this.lifePathNumber,
    required this.expressionNumber,
    required this.soulUrgeNumber,
    required this.personalityNumber,
    required this.birthdayNumber,
  });
}

class NumerologyCalculator {
  static const Map<String, int> _letterValues = {
    'a': 1, 'j': 1, 's': 1,
    'b': 2, 'k': 2, 't': 2,
    'c': 3, 'l': 3, 'u': 3,
    'd': 4, 'm': 4, 'v': 4,
    'e': 5, 'n': 5, 'w': 5,
    'f': 6, 'o': 6, 'x': 6,
    'g': 7, 'p': 7, 'y': 7,
    'h': 8, 'q': 8, 'z': 8,
    'i': 9, 'r': 9,
  };

  static const Set<String> _vowels = {'a', 'e', 'i', 'o', 'u'};

  // Normalize Turkish letters to ASCII equivalents for calculation
  static String _normalize(String s) => s
      .toLowerCase()
      .replaceAll('ç', 'c')
      .replaceAll('ğ', 'g')
      .replaceAll('ı', 'i')
      .replaceAll('İ'.toLowerCase(), 'i')
      .replaceAll('ö', 'o')
      .replaceAll('ş', 's')
      .replaceAll('ü', 'u');

  // Reduce number to single digit, preserving master numbers 11, 22, 33
  static int reduce(int n) {
    while (n > 9 && n != 11 && n != 22 && n != 33) {
      n = n.toString().split('').fold(0, (sum, d) => sum + int.parse(d));
    }
    return n;
  }

  static int calculateLifePath(DateTime date) {
    final month = reduce(date.month);
    final day = reduce(date.day);
    final yearDigitSum = date.year
        .toString()
        .split('')
        .fold(0, (sum, d) => sum + int.parse(d));
    final year = reduce(yearDigitSum);
    return reduce(month + day + year);
  }

  static int calculateExpression(String name) => _nameNumber(name);
  static int calculateSoulUrge(String name) =>
      _nameNumber(name, vowelsOnly: true);
  static int calculatePersonality(String name) =>
      _nameNumber(name, consonantsOnly: true);

  static int _nameNumber(String name,
      {bool vowelsOnly = false, bool consonantsOnly = false}) {
    final chars = _normalize(name).split('');
    int sum = 0;
    for (final ch in chars) {
      if (!RegExp(r'[a-z]').hasMatch(ch)) continue;
      final isVowel = _vowels.contains(ch);
      if (vowelsOnly && !isVowel) continue;
      if (consonantsOnly && isVowel) continue;
      sum += _letterValues[ch] ?? 0;
    }
    return sum == 0 ? 0 : reduce(sum);
  }

  static NumerologyResult calculate({
    required String name,
    required DateTime birthDate,
  }) {
    final hasName = name.trim().isNotEmpty;
    return NumerologyResult(
      name: name,
      birthDate: birthDate,
      lifePathNumber: calculateLifePath(birthDate),
      expressionNumber: hasName ? _nameNumber(name) : 0,
      soulUrgeNumber: hasName ? _nameNumber(name, vowelsOnly: true) : 0,
      personalityNumber: hasName ? _nameNumber(name, consonantsOnly: true) : 0,
      birthdayNumber: reduce(birthDate.day),
    );
  }
}
