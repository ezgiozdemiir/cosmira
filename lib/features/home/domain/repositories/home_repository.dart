import '../../../../core/utils/result.dart';
import '../entities/daily_horoscope.dart';

abstract class HomeRepository {
  Future<Result<DailyHoroscope>> getTodayHoroscope(String sign, {String point = 'sun', String language = 'en'});
  Future<Result<int>> getStardustBalance(String userId);
  Future<Result<int>> getStreak(String userId);
  Future<Result<void>> claimDailyLogin(String userId);
}
