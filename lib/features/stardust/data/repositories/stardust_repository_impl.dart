import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/stardust_transaction.dart';
import '../../domain/repositories/stardust_repository.dart';
import '../models/stardust_transaction_model.dart';

class StardustRepositoryImpl implements StardustRepository {
  final SupabaseClient _client;

  StardustRepositoryImpl(this._client);

  @override
  Future<Result<int>> getBalance(String userId) async {
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
  Future<Result<List<StardustTransaction>>> getTransactions(String userId) async {
    try {
      final data = await _client
          .from('stardust_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      final transactions = (data as List)
          .map((j) => StardustTransactionModel.fromJson(j))
          .toList();
      return Result.success(transactions);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> earnStardust({
    required String userId,
    required int amount,
    required String source,
    required String description,
  }) async {
    try {
      final result = await _client.rpc('earn_stardust', params: {
        'p_user_id': userId,
        'p_amount': amount,
        'p_source': source,
        'p_description': description,
      });

      return Result.success(result as int);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> spendStardust({
    required String userId,
    required int amount,
    required String description,
  }) async {
    try {
      final result = await _client.rpc('spend_stardust', params: {
        'p_user_id': userId,
        'p_amount': amount,
        'p_description': description,
      });

      // The SQL function returns BOOLEAN: FALSE = insufficient balance, TRUE = success.
      if (result == false) {
        return Result.failure(
          InsufficientStardustFailure(required: amount, available: 0),
        );
      }
      return Result.success(amount);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
