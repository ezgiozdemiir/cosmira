class HouseDetail {
  final int house;
  final String sign;
  final String theme;
  final String interpretation;

  const HouseDetail({
    required this.house,
    required this.sign,
    required this.theme,
    required this.interpretation,
  });

  factory HouseDetail.fromJson(Map<String, dynamic> json) => HouseDetail(
        house: (json['house'] as num).toInt(),
        sign: _toEnglishSign(json['sign'] as String),
        theme: json['theme'] as String,
        interpretation: json['interpretation'] as String,
      );

  static String _toEnglishSign(String sign) {
    const trToEn = {
      'koç': 'aries',         'koc': 'aries',
      'boğa': 'taurus',       'boga': 'taurus',
      'ikizler': 'gemini',    'i̇kizler': 'gemini',
      'yengeç': 'cancer',     'yengec': 'cancer',
      'aslan': 'leo',
      'başak': 'virgo',       'basak': 'virgo',
      'terazi': 'libra',
      'akrep': 'scorpio',
      'yay': 'sagittarius',
      'oğlak': 'capricorn',   'oglak': 'capricorn',
      'kova': 'aquarius',
      'balık': 'pisces',      'balik': 'pisces',
    };
    final lower = sign.toLowerCase();
    return trToEn[lower] ?? lower;
  }
}

class HouseInsight {
  final String risingSign;
  final List<HouseDetail> houses;

  const HouseInsight({required this.risingSign, required this.houses});

  factory HouseInsight.fromJson(Map<String, dynamic> json) {
    final raw = json['content'] as List<dynamic>;
    return HouseInsight(
      risingSign: json['rising_sign'] as String,
      houses: raw.map((e) => HouseDetail.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
