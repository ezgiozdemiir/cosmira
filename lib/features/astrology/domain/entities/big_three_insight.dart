/// A piece of AI-generated content keyed by a Sun/Moon/Rising sign
/// combination rather than by user — shared across every user with the
/// same Big Three. [content] shape varies by [period] (personality
/// summary vs. daily/monthly/yearly forecast), so it's kept as a raw map
/// rather than one bespoke class per shape.
class BigThreeInsight {
  final String tier;
  final String period;
  final Map<String, dynamic> content;

  const BigThreeInsight({
    required this.tier,
    required this.period,
    required this.content,
  });

  factory BigThreeInsight.fromJson(Map<String, dynamic> json) {
    return BigThreeInsight(
      tier: json['tier'] as String,
      period: json['period'] as String,
      content: json['content'] as Map<String, dynamic>,
    );
  }
}
