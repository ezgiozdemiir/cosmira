import '../../../../core/utils/result.dart';
import '../entities/loved_one.dart';

abstract class LovedOnesRepository {
  /// All loved ones the user has saved, newest first.
  Future<Result<List<LovedOne>>> getAll(String userId);

  /// Saves a new loved one. [sunSign]/[moonSign]/[risingSign]/[birthLat]/
  /// [birthLng] must already be computed (e.g. via
  /// `AstrologyRepository.calculateBigThree`) before calling this — rows
  /// are immutable once created, so get the chart right up front.
  Future<Result<LovedOne>> add({
    required String userId,
    required String name,
    String? gender,
    required DateTime birthDate,
    required String birthTime,
    required String birthCity,
    double? birthLat,
    double? birthLng,
    required String sunSign,
    required String moonSign,
    required String risingSign,
    String? mcSign,
  });

  /// Deletes a loved one (and cascades to any generated reports/unlocks).
  Future<Result<void>> delete(String lovedOneId);
}
