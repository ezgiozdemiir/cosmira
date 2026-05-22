import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/daily_horoscope.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/daily_horoscope_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final SupabaseClient _client;

  HomeRepositoryImpl(this._client);

  @override
  Future<Result<DailyHoroscope>> getTodayHoroscope(String sign) async {
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      final data = await _client
          .from('daily_horoscopes')
          .select()
          .eq('sign', sign)
          .eq('date', today)
          .single();

      return Result.success(DailyHoroscopeModel.fromJson(data));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> getStardustBalance(String userId) async {
    try {
      final data = await _client
          .from('stardust_wallets')
          .select('balance')
          .eq('user_id', userId)
          .single();

      return Result.success(data['balance'] as int);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> getStreak(String userId) async {
    try {
      final data = await _client
          .from('user_streaks')
          .select('current_streak')
          .eq('user_id', userId)
          .single();

      return Result.success(data['current_streak'] as int);
    } catch (e) {
      return Result.success(0);
    }
  }

  @override
  Future<Result<void>> claimDailyLogin(String userId) async {
    try {
      await _client.rpc('earn_stardust', params: {
        'p_user_id': userId,
        'p_amount': 5,
        'p_source': 'daily_login',
        'p_description': 'Daily login reward',
      });
      return Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
