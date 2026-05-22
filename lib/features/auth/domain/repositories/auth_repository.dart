import '../../../../core/utils/result.dart';
import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<Result<void>> signInWithApple();
  Future<Result<void>> signInWithGoogle();
  Future<Result<void>> signOut();
  Future<Result<UserProfile>> getCurrentProfile();
  Future<Result<UserProfile>> updateProfile(UserProfile profile);
  Stream<UserProfile?> watchProfile();
}
