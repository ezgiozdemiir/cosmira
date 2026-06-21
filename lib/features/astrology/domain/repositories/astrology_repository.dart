import '../../../../core/utils/result.dart';
import '../../../home/domain/entities/daily_horoscope.dart';
import '../entities/big_three_insight.dart';
import '../entities/big_three_result.dart';
import '../entities/birth_map.dart';
import '../entities/house_insight.dart';
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

  /// Computes Sun/Moon/Rising signs from birth date, time, and city via the
  /// `calculate-natal-chart` edge function. Geocoding and timezone handling
  /// happen server-side, so this works the same on every platform.
  Future<Result<BigThreeResult>> calculateBigThree({
    required DateTime birthDate,
    required String birthTime,
    required String birthCity,
  });

  /// Fetches (or triggers generation of) a Big-Three-keyed insight via the
  /// `generate-big-three-insight` edge function. [tier] is `'free'` or
  /// `'premium'`; [period] is `'static'`, `'daily'`, `'monthly'`, or
  /// `'yearly'`.
  Future<Result<BigThreeInsight>> getBigThreeInsight({
    required String sunSign,
    required String moonSign,
    required String risingSign,
    required String tier,
    required String period,
    String language = 'en',
  });

  Future<Result<HouseInsight>> getHouseInsights({
    required String risingSign,
    String language = 'en',
  });

  Future<Result<bool>> hasBirthMap(String userId);
  Future<Result<BirthMap?>> getBirthMap(String userId, {String language = 'en'});
  Future<Result<BirthMap>> generateBirthMap({
    required String sunSign,
    required String moonSign,
    required String risingSign,
    required String mcSign,
    required String birthDate,
    required String birthCity,
    String language = 'en',
  });
}
