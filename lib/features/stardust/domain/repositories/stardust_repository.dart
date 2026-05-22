import '../../../../core/utils/result.dart';
import '../entities/stardust_transaction.dart';

abstract class StardustRepository {
  Future<Result<int>> getBalance(String userId);
  Future<Result<List<StardustTransaction>>> getTransactions(String userId);
  Future<Result<int>> earnStardust({
    required String userId,
    required int amount,
    required String source,
    required String description,
  });
  Future<Result<int>> spendStardust({
    required String userId,
    required int amount,
    required String description,
  });
}
