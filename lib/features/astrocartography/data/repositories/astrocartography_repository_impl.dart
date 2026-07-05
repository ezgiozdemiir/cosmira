import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/astrocartography_lines.dart';
import '../../domain/entities/astrocartography_unlock.dart';
import '../../domain/repositories/astrocartography_repository.dart';

class AstrocartographyRepositoryImpl implements AstrocartographyRepository {
  final SupabaseClient _client;

  AstrocartographyRepositoryImpl(this._client);

  @override
  Future<Result<bool>> hasUnlock({
    required String userId,
    required int birthDataVersion,
  }) async {
    try {
      final data = await _client
          .from('astrocartography_unlocks')
          .select('id')
          .eq('user_id', userId)
          .eq('birth_data_version', birthDataVersion)
          .maybeSingle();
      return Result.success(data != null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> unlock({
    required String userId,
    required int amount,
    String? birthCity,
  }) async {
    try {
      final result = await _client.rpc('unlock_astrocartography', params: {
        'p_user_id': userId,
        'p_amount': amount,
        'p_birth_city': birthCity,
      }) as Map<String, dynamic>;

      final success = result['success'] as bool? ?? false;
      if (!success) {
        return Result.failure(
          InsufficientStardustFailure(required: amount, available: 0),
        );
      }
      return Result.success(result['charged'] as bool? ?? false);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<AstrocartographyUnlock>>> getHistory(String userId) async {
    try {
      final data = await _client
          .from('astrocartography_unlocks')
          .select()
          .eq('user_id', userId)
          .order('birth_data_version', ascending: false);

      final unlocks = (data as List)
          .map((j) => AstrocartographyUnlock.fromJson(j as Map<String, dynamic>))
          .toList();
      return Result.success(unlocks);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> hasUnlockForLovedOne(String lovedOneId) async {
    try {
      final data = await _client
          .from('loved_one_astrocartography_unlocks')
          .select('id')
          .eq('loved_one_id', lovedOneId)
          .maybeSingle();
      return Result.success(data != null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> unlockForLovedOne({
    required String lovedOneId,
    required int amount,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return Result.failure(const AuthFailure('Not logged in'));

      final result = await _client.rpc('unlock_astrocartography_for_loved_one', params: {
        'p_user_id': userId,
        'p_loved_one_id': lovedOneId,
        'p_amount': amount,
      }) as Map<String, dynamic>;

      final success = result['success'] as bool? ?? false;
      if (!success) {
        return Result.failure(
          InsufficientStardustFailure(required: amount, available: 0),
        );
      }
      return Result.success(result['charged'] as bool? ?? false);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<AstrocartographyLines>> getLines({
    required DateTime birthDate,
    required String birthTime,
    required String birthCity,
    String? lovedOneId,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'calculate-astrocartography-lines',
        body: {
          'birth_date': birthDate.toIso8601String().split('T').first,
          'birth_time': birthTime,
          'birth_city': birthCity,
          if (lovedOneId != null) 'loved_one_id': lovedOneId,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return Result.success(
          AstrocartographyLines.fromJson(data['lines'] as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
