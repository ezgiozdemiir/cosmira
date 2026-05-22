import '../../../../core/utils/result.dart';
import '../entities/moon_phase.dart';

abstract class MoonRepository {
  Future<Result<MoonPhase>> getCurrentMoonPhase();
  Future<Result<List<MoonPhase>>> getMonthlyPhases(int year, int month);
}
