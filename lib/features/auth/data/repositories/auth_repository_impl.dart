import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_profile_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  AuthRepositoryImpl(this._client);

  // On web the browser cannot handle a custom-scheme URL, so we omit
  // redirectTo and let Supabase use the current page origin.  On mobile
  // we use the registered custom scheme so the OS routes the callback
  // back into the app.
  static String? get _redirectTo =>
      kIsWeb ? null : 'io.cosmira.app://login-callback';

  @override
  Future<Result<void>> signInWithApple() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: _redirectTo,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _redirectTo,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _client.auth.signOut();
      return Result.success(null);
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserProfile>> getCurrentProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return Result.failure(AuthFailure('Not logged in'));

      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return Result.success(UserProfileModel.fromJson(data));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserProfile>> updateProfile(UserProfile profile) async {
    try {
      final model = UserProfileModel(
        id: profile.id,
        displayName: profile.displayName,
        avatarUrl: profile.avatarUrl,
        birthDate: profile.birthDate,
        birthTime: profile.birthTime,
        birthCity: profile.birthCity,
        birthLat: profile.birthLat,
        birthLng: profile.birthLng,
        sunSign: profile.sunSign,
        moonSign: profile.moonSign,
        risingSign: profile.risingSign,
        subscriptionTier: profile.subscriptionTier,
        onboardingComplete: profile.onboardingComplete,
        createdAt: profile.createdAt,
      );

      final data = await _client
          .from('profiles')
          .update(model.toJson())
          .eq('id', profile.id)
          .select()
          .single();

      return Result.success(UserProfileModel.fromJson(data));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<UserProfile?> watchProfile() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return Stream.value(null);

    return _client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) {
          if (data.isEmpty) return null;
          return UserProfileModel.fromJson(data.first);
        });
  }
}
