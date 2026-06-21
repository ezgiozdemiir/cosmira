import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/compatibility_partner.dart';
import '../../domain/repositories/compatibility_repository.dart';
import '../models/compatibility_models.dart';

class CompatibilityRepositoryImpl implements CompatibilityRepository {
  final SupabaseClient _client;

  CompatibilityRepositoryImpl(this._client);

  @override
  Future<Result<List<CompatibilityPartner>>> getPartners(String userId) async {
    try {
      final data = await _client
          .from('compatibility_partners')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final partners =
          (data as List).map((j) => CompatibilityPartnerModel.fromJson(j)).toList();
      return Result.success(partners);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<CompatibilityPartner>> addPartner(CompatibilityPartner partner) async {
    try {
      final data = await _client.from('compatibility_partners').insert({
        'user_id': partner.userId,
        'name': partner.name,
        'birth_date': partner.birthDate.toIso8601String().split('T').first,
        'birth_time': partner.birthTime,
        'birth_city': partner.birthCity,
        'birth_lat': partner.birthLat,
        'birth_lng': partner.birthLng,
        'sun_sign': partner.sunSign,
        'relationship': partner.relationship,
      }).select().single();

      return Result.success(CompatibilityPartnerModel.fromJson(data));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> removePartner(String partnerId) async {
    try {
      await _client.from('compatibility_partners').delete().eq('id', partnerId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<CompatibilityReport?>> getReport(
    String userId,
    String partnerId, {
    String language = 'en',
  }) async {
    try {
      final data = await _client
          .from('compatibility_reports')
          .select()
          .eq('user_id', userId)
          .eq('partner_id', partnerId)
          .eq('language', language)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data == null) return Result.success(null);
      return Result.success(CompatibilityReportModel.fromJson(data));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<CompatibilityReport>> generateReport(
    String partnerId, {
    String language = 'en',
  }) async {
    try {
      final response = await _client.functions.invoke(
        'generate-compatibility-report',
        body: {'partner_id': partnerId, 'language': language},
      );
      final data = (response.data as Map<String, dynamic>)['report']
          as Map<String, dynamic>;
      return Result.success(CompatibilityReportModel.fromJson(data));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
