String sunSignFromDate(DateTime date) {
  final m = date.month;
  final d = date.day;
  if ((m == 3 && d >= 21) || (m == 4 && d <= 19)) return 'aries';
  if ((m == 4 && d >= 20) || (m == 5 && d <= 20)) return 'taurus';
  if ((m == 5 && d >= 21) || (m == 6 && d <= 20)) return 'gemini';
  if ((m == 6 && d >= 21) || (m == 7 && d <= 22)) return 'cancer';
  if ((m == 7 && d >= 23) || (m == 8 && d <= 22)) return 'leo';
  if ((m == 8 && d >= 23) || (m == 9 && d <= 22)) return 'virgo';
  if ((m == 9 && d >= 23) || (m == 10 && d <= 22)) return 'libra';
  if ((m == 10 && d >= 23) || (m == 11 && d <= 21)) return 'scorpio';
  if ((m == 11 && d >= 22) || (m == 12 && d <= 21)) return 'sagittarius';
  if ((m == 12 && d >= 22) || (m == 1 && d <= 19)) return 'capricorn';
  if ((m == 1 && d >= 20) || (m == 2 && d <= 18)) return 'aquarius';
  return 'pisces';
}

const List<String> zodiacSigns = [
  'aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
  'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces',
];

/// The sign directly opposite [sign] on the zodiac wheel (180 degrees away,
/// i.e. 6 signs further around). Used to derive the Descendant from the
/// Ascendant, and the Imum Coeli from the Midheaven.
String oppositeSign(String sign) {
  final index = zodiacSigns.indexOf(sign.toLowerCase());
  if (index == -1) return sign;
  return zodiacSigns[(index + 6) % 12];
}

/// Whole-sign houses: House 1 is the Ascendant's entire sign, House 2 is
/// the next sign around the wheel, and so on.
List<String> wholeSignHouses(String risingSign) {
  final index = zodiacSigns.indexOf(risingSign.toLowerCase());
  if (index == -1) return const [];
  return List.generate(12, (i) => zodiacSigns[(index + i) % 12]);
}
