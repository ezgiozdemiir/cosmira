import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/loved_one.dart';
import '../../domain/repositories/loved_ones_repository.dart';

class LovedOnesRepositoryImpl implements LovedOnesRepository {
  final SupabaseClient _client;

  LovedOnesRepositoryImpl(this._client);

  @override
  Future<Result<List<LovedOne>>> getAll(String userId) async {
    try {
      final data = await _client
          .from('loved_ones')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final list = (data as List)
          .map((j) => LovedOne.fromJson(j as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final data = await _client
          .from('loved_ones')
          .insert({
            'user_id': userId,
            'name': name,
            'gender': gender,
            'birth_date': birthDate.toIso8601String().split('T').first,
            'birth_time': birthTime,
            'birth_city': birthCity,
            'birth_lat': birthLat,
            'birth_lng': birthLng,
            'sun_sign': sunSign,
            'moon_sign': moonSign,
            'rising_sign': risingSign,
            'mc_sign': mcSign,
          })
          .select()
          .single();
      return Result.success(LovedOne.fromJson(data));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> delete(String lovedOneId) async {
    try {
      await _client.from('loved_ones').delete().eq('id', lovedOneId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
