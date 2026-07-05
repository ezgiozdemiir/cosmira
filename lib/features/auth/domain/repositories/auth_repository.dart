import '../../../../core/utils/result.dart';
import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<Result<void>> signInWithApple();
  Future<Result<void>> signInWithGoogle();
  Future<Result<void>> signInWithEmail(String email, String password);
  Future<Result<bool>> signUpWithEmail(String email, String password, String name);
  Future<Result<void>> resendConfirmationEmail(String email);
  Future<Result<void>> signOut();
  Future<Result<UserProfile>> getCurrentProfile();
  Future<Result<UserProfile>> updateProfile(UserProfile profile);

  /// Atomically changes birth date/time/city (+ derived signs) against the
  /// lifetime edit cap, via the `edit_birth_data` RPC. Returns the number of
  /// changes remaining on success, or [EditLimitReachedFailure] once the
  /// plan's cap (free: 2, pro: 5) has been used up.
  Future<Result<int>> editBirthData({
    required DateTime birthDate,
    required String birthTime,
    required String birthCity,
    double? birthLat,
    double? birthLng,
    required String sunSign,
    String? moonSign,
    String? risingSign,
    String? mcSign,
  });

  Stream<UserProfile?> watchProfile();
}
