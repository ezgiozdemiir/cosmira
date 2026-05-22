import '../../../../core/utils/result.dart';
import '../../../home/domain/entities/daily_horoscope.dart';
import '../entities/natal_chart.dart';

abstract class AstrologyRepository {
  Future<Result<NatalChart>> getNatalChart(String userId);
  Future<Result<NatalChart>> calculateNatalChart({
    required String userId,
    required DateTime birthDate,
    required String? birthTime,
    required double latitude,
    required double longitude,
  });
  Future<Result<List<DailyHoroscope>>> getWeeklyHoroscopes(String sign);
}
