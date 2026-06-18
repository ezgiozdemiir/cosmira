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
        sign: json['sign'] as String,
        theme: json['theme'] as String,
        interpretation: json['interpretation'] as String,
      );
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
