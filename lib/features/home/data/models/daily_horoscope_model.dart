import '../../domain/entities/daily_horoscope.dart';

class DailyHoroscopeModel extends DailyHoroscope {
  const DailyHoroscopeModel({
    required super.id,
    required super.sign,
    required super.date,
    required super.horoscopeText,
    required super.energyScore,
    required super.auraColor,
    required super.luckyNumber,
    required super.mood,
    required super.dailyQuote,
    required super.spiritualInsight,
    super.spotifyTrackId,
    super.spotifyTrackName,
    super.spotifyArtist,
  });

  factory DailyHoroscopeModel.fromJson(Map<String, dynamic> json) {
    return DailyHoroscopeModel(
      id: json['id'] as String,
      sign: json['sign'] as String,
      date: DateTime.parse(json['date'] as String),
      horoscopeText: json['horoscope_text'] as String,
      energyScore: json['energy_score'] as int,
      auraColor: json['aura_color'] as String,
      luckyNumber: json['lucky_number'] as int,
      mood: json['mood'] as String,
      dailyQuote: json['daily_quote'] as String,
      spiritualInsight: json['spiritual_insight'] as String,
      spotifyTrackId: json['spotify_track_id'] as String?,
      spotifyTrackName: json['spotify_track_name'] as String?,
      spotifyArtist: json['spotify_artist'] as String?,
    );
  }
}
