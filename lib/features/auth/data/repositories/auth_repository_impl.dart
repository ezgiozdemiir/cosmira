import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/web_utils_stub.dart'
    if (dart.library.js_interop) '../../../../core/utils/web_utils_html.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_profile_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  AuthRepositoryImpl(this._client);

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
      if (kIsWeb) {
        // Open the OAuth URL in a popup window instead of navigating the current
        // tab. The full-page redirect causes Google's sign-in page to load with
        // an autofocused field that won't accept keyboard input (permanent tab
        // spinner). A popup opens a fresh browser context where Google's page
        // works normally. After sign-in, the popup's Supabase init processes the
        // code, stores the session in localStorage, then closes itself. The
        // parent tab reloads and Supabase reads the session from localStorage.
        final response = await _client.auth.getOAuthSignInUrl(
          provider: OAuthProvider.google,
          redirectTo: '${Uri.base.origin}/',
        );
        await openOAuthPopupAndWait(response.url);
        return Result.success(null);
      }
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
      if (userId == null) return Result.failure(const AuthFailure('Not logged in'));

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
        firstName: profile.firstName,
        lastName: profile.lastName,
        gender: profile.gender,
        avatarUrl: profile.avatarUrl,
        birthDate: profile.birthDate,
        birthTime: profile.birthTime,
        birthCity: profile.birthCity,
        birthLat: profile.birthLat,
        birthLng: profile.birthLng,
        sunSign: profile.sunSign,
        moonSign: profile.moonSign,
        risingSign: profile.risingSign,
        mcSign: profile.mcSign,
        subscriptionTier: profile.subscriptionTier,
        onboardingComplete: profile.onboardingComplete,
        createdAt: profile.createdAt,
      );

      final data = await _client
          .from('profiles')
          .upsert(model.toJson())
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
