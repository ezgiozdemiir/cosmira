import 'package:equatable/equatable.dart';

/// One historical unlock of the Astrocartography report, snapshotting the
/// birth city in effect at the time — Astrocartography's content is mostly
/// static, so the birth city is the only thing meaningfully tied to a
/// specific birth-data version.
class AstrocartographyUnlock extends Equatable {
  final int birthDataVersion;
  final String? birthCity;
  final DateTime unlockedAt;

  const AstrocartographyUnlock({
    required this.birthDataVersion,
    required this.birthCity,
    required this.unlockedAt,
  });

  factory AstrocartographyUnlock.fromJson(Map<String, dynamic> json) =>
      AstrocartographyUnlock(
        birthDataVersion: (json['birth_data_version'] as num).toInt(),
        birthCity: json['birth_city'] as String?,
        unlockedAt: DateTime.parse(json['unlocked_at'] as String),
      );

  @override
  List<Object?> get props => [birthDataVersion, birthCity, unlockedAt];
}
