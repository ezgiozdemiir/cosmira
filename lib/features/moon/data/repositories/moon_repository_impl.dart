import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/moon_phase.dart';
import '../../domain/repositories/moon_repository.dart';
import '../models/moon_phase_model.dart';

class MoonRepositoryImpl implements MoonRepository {
  final SupabaseClient _client;

  MoonRepositoryImpl(this._client);

  @override
  Future<Result<MoonPhase>> getCurrentMoonPhase() async {
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      final data = await _client
          .from('moon_phases')
          .select()
          .lte('date', today)
          .order('date', ascending: false)
          .limit(1)
          .single();

      return Result.success(MoonPhaseModel.fromJson(data));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<MoonPhase>>> getMonthlyPhases(int year, int month) async {
    try {
      final startDate = DateTime(year, month, 1).toIso8601String().split('T').first;
      final endDate = DateTime(year, month + 1, 0).toIso8601String().split('T').first;

      final data = await _client
          .from('moon_phases')
          .select()
          .gte('date', startDate)
          .lte('date', endDate)
          .order('date');

      final phases =
          (data as List).map((j) => MoonPhaseModel.fromJson(j)).toList();
      return Result.success(phases);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
