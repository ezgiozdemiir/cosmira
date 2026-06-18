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
