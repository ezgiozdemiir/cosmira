import 'package:equatable/equatable.dart';

/// A saved person (partner, parent, friend...) whose birth data a user has
/// entered to generate a Birth Map / Astrocartography report as a gift.
/// Field names mirror [UserProfile]'s (sunSign/moonSign/risingSign/mcSign)
/// so this duck-types identically wherever a report-rendering widget
/// expects a loosely-typed `profile`.
class LovedOne extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? gender;
  final DateTime birthDate;
  final String birthTime;
  final String birthCity;
  final double? birthLat;
  final double? birthLng;
  final String sunSign;
  final String moonSign;
  final String risingSign;
  final String? mcSign;
  final DateTime createdAt;

  const LovedOne({
    required this.id,
    required this.userId,
    required this.name,
    this.gender,
    required this.birthDate,
    required this.birthTime,
    required this.birthCity,
    this.birthLat,
    this.birthLng,
    required this.sunSign,
    required this.moonSign,
    required this.risingSign,
    this.mcSign,
    required this.createdAt,
  });

  factory LovedOne.fromJson(Map<String, dynamic> json) => LovedOne(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String,
        gender: json['gender'] as String?,
        birthDate: DateTime.parse(json['birth_date'] as String),
        birthTime: json['birth_time'] as String,
        birthCity: json['birth_city'] as String,
        birthLat: (json['birth_lat'] as num?)?.toDouble(),
        birthLng: (json['birth_lng'] as num?)?.toDouble(),
        sunSign: json['sun_sign'] as String,
        moonSign: json['moon_sign'] as String,
        risingSign: json['rising_sign'] as String,
        mcSign: json['mc_sign'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  @override
  List<Object?> get props => [id, userId, name];
}
