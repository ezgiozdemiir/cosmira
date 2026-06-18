import 'package:equatable/equatable.dart';

class DailyHoroscope extends Equatable {
  final String id;
  final String sign;
  final String point;
  final DateTime date;
  final String horoscopeText;
  final int energyScore;
  final String auraColor;
  final int luckyNumber;
  final String mood;
  final String dailyQuote;
  final String spiritualInsight;
  final String? spotifyTrackId;
  final String? spotifyTrackName;
  final String? spotifyArtist;

  const DailyHoroscope({
    required this.id,
    required this.sign,
    this.point = 'sun',
    required this.date,
    required this.horoscopeText,
    required this.energyScore,
    required this.auraColor,
    required this.luckyNumber,
    required this.mood,
    required this.dailyQuote,
    required this.spiritualInsight,
    this.spotifyTrackId,
    this.spotifyTrackName,
    this.spotifyArtist,
  });

  @override
  List<Object?> get props => [id, sign, point, date];
}
