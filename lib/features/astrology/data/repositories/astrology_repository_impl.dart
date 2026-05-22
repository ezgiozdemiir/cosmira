import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../home/domain/entities/daily_horoscope.dart';
import '../../../home/data/models/daily_horoscope_model.dart';
import '../../domain/entities/natal_chart.dart';
import '../../domain/repositories/astrology_repository.dart';
import '../models/natal_chart_model.dart';

class AstrologyRepositoryImpl implements AstrologyRepository {
  final SupabaseClient _client;

  AstrologyRepositoryImpl(this._client);

  @override
  Future<Result<NatalChart>> getNatalChart(String userId) async {
    try {
      final data = await _client
          .from('natal_charts')
          .select()
          .eq('user_id', userId)
          .single();

      return Result.success(NatalChartModel.fromJson(data));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<NatalChart>> calculateNatalChart({
    required String userId,
    required DateTime birthDate,
    required String? birthTime,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'calculate-natal-chart',
        body: {
          'user_id': userId,
          'birth_date': birthDate.toIso8601String(),
          'birth_time': birthTime,
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return Result.success(NatalChartModel.fromJson(data['chart']));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<DailyHoroscope>>> getWeeklyHoroscopes(String sign) async {
    try {
      final today = DateTime.now();
      final weekAgo = today.subtract(const Duration(days: 7));

      final data = await _client
          .from('daily_horoscopes')
          .select()
          .eq('sign', sign)
          .gte('date', weekAgo.toIso8601String().split('T').first)
          .lte('date', today.toIso8601String().split('T').first)
          .order('date');

      final horoscopes =
          (data as List).map((j) => DailyHoroscopeModel.fromJson(j)).toList();
      return Result.success(horoscopes);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
