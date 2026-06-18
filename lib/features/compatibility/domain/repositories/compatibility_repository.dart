import '../../../../core/utils/result.dart';
import '../entities/compatibility_partner.dart';

abstract class CompatibilityRepository {
  Future<Result<List<CompatibilityPartner>>> getPartners(String userId);
  Future<Result<CompatibilityPartner>> addPartner(CompatibilityPartner partner);
  Future<Result<void>> removePartner(String partnerId);
  Future<Result<CompatibilityReport?>> getReport(String userId, String partnerId);
  Future<Result<CompatibilityReport>> generateReport(String partnerId);
}
