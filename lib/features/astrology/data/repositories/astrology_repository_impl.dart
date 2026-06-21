import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../home/domain/entities/daily_horoscope.dart';
import '../../../home/data/models/daily_horoscope_model.dart';
import '../../domain/entities/big_three_insight.dart';
import '../../domain/entities/big_three_result.dart';
import '../../domain/entities/birth_map.dart';
import '../../domain/entities/house_insight.dart';
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

  @override
  Future<Result<BigThreeResult>> calculateBigThree({
    required DateTime birthDate,
    required String birthTime,
    required String birthCity,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'calculate-natal-chart',
        body: {
          'birth_date': birthDate.toIso8601String().split('T').first,
          'birth_time': birthTime,
          'birth_city': birthCity,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return Result.success(BigThreeResult(
        sunSign: data['sun_sign'] as String,
        moonSign: data['moon_sign'] as String,
        risingSign: data['rising_sign'] as String,
        mcSign: data['mc_sign'] as String,
        birthLat: (data['birth_lat'] as num).toDouble(),
        birthLng: (data['birth_lng'] as num).toDouble(),
      ));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<BigThreeInsight>> getBigThreeInsight({
    required String sunSign,
    required String moonSign,
    required String risingSign,
    required String tier,
    required String period,
    String language = 'en',
  }) async {
    try {
      final response = await _client.functions.invoke(
        'generate-big-three-insight',
        body: {
          'sun_sign': sunSign,
          'moon_sign': moonSign,
          'rising_sign': risingSign,
          'tier': tier,
          'period': period,
          'language': language,
        },
      );

      final insightData =
          (response.data as Map<String, dynamic>)['insight'] as Map<String, dynamic>;
      return Result.success(BigThreeInsight.fromJson(insightData));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<HouseInsight>> getHouseInsights({
    required String risingSign,
    String language = 'en',
  }) async {
    try {
      final response = await _client.functions.invoke(
        'generate-house-insights',
        body: {'rising_sign': risingSign, 'language': language},
      );
      final insightData =
          (response.data as Map<String, dynamic>)['insight'] as Map<String, dynamic>;
      return Result.success(HouseInsight.fromJson(insightData));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> hasBirthMap(String userId) async {
    try {
      final data = await _client
          .from('birth_maps')
          .select('id')
          .eq('user_id', userId)
          .limit(1)
          .maybeSingle();
      return Result.success(data != null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<BirthMap?>> getBirthMap(String userId, {String language = 'en'}) async {
    try {
      final data = await _client
          .from('birth_maps')
          .select()
          .eq('user_id', userId)
          .eq('language', language)
          .maybeSingle();
      if (data == null) return Result.success(null);
      return Result.success(BirthMap.fromJson(data));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<BirthMap>> generateBirthMap({
    required String sunSign,
    required String moonSign,
    required String risingSign,
    required String mcSign,
    required String birthDate,
    required String birthCity,
    String language = 'en',
  }) async {
    try {
      final response = await _client.functions.invoke(
        'generate-birth-map',
        body: {
          'sun_sign': sunSign,
          'moon_sign': moonSign,
          'rising_sign': risingSign,
          'mc_sign': mcSign,
          'birth_date': birthDate,
          'birth_city': birthCity,
          'language': language,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return Result.success(
          BirthMap.fromJson(data['birth_map'] as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
