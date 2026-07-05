import 'dart:async';

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
  Future<Result<void>> signInWithEmail(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      return Result.success(null);
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> signUpWithEmail(String email, String password, String name) async {
    try {
      final displayName = name.trim().isEmpty ? email.split('@').first : name.trim();
      final emailRedirectTo = kIsWeb
          ? '${Uri.base.origin}/confirm-email'
          : 'io.cosmira.app://confirm-callback';
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: emailRedirectTo,
        data: {
          'full_name': displayName,
          'display_name': displayName,
        },
      );
      // user == null → outright rejection (very rare).
      if (response.user == null) {
        return Result.failure(const AuthFailure(
          'Could not create account. Please try again later.',
        ));
      }
      // identities == [] → Supabase's email-enumeration protection: the email
      // is already registered and confirmed. Return the localised error key so
      // the UI shows "Email already in use" instead of the confirm-email screen.
      if (response.user!.identities?.isEmpty == true) {
        return Result.failure(const AuthFailure('auth_err_email_exists'));
      }
      // session == null (with a valid user) means email confirmation is required.
      return Result.success(response.session == null);
    } catch (e) {
      return Result.failure(AuthFailure(_mapAuthError(e)));
    }
  }

  @override
  Future<Result<void>> resendConfirmationEmail(String email) async {
    try {
      await _client.auth.resend(type: OtpType.signup, email: email);
      return Result.success(null);
    } catch (e) {
      return Result.failure(AuthFailure(_mapAuthError(e)));
    }
  }

  static String _mapAuthError(Object e) {
    if (e is AuthApiException) {
      switch (e.code) {
        case 'over_email_send_rate_limit':
          return 'auth_err_rate_limit';
        case 'email_exists':
        case 'user_already_exists':
          return 'auth_err_email_exists';
        case 'invalid_credentials':
          return 'auth_err_invalid_credentials';
        case 'weak_password':
          return 'auth_err_weak_password';
        default:
          return e.message;
      }
    }
    return e.toString();
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
          .maybeSingle();

      if (data == null) return Result.failure(const AuthFailure('Profile not found'));
      return Result.success(UserProfileModel.fromJson(data));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return Result.failure(const AuthFailure('Not logged in'));

      final response = await _client.rpc('edit_birth_data', params: {
        'p_user_id': userId,
        'p_birth_date': birthDate.toIso8601String().split('T').first,
        'p_birth_time': birthTime,
        'p_birth_city': birthCity,
        'p_birth_lat': birthLat,
        'p_birth_lng': birthLng,
        'p_sun_sign': sunSign,
        'p_moon_sign': moonSign,
        'p_rising_sign': risingSign,
        'p_mc_sign': mcSign,
      }) as Map<String, dynamic>;

      final success = response['success'] as bool? ?? false;
      final limit = (response['limit'] as num?)?.toInt() ?? 0;
      if (!success) {
        return Result.failure(EditLimitReachedFailure(used: limit, limit: limit));
      }
      return Result.success((response['remaining'] as num?)?.toInt() ?? 0);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserProfile>> updateProfile(UserProfile profile) async {
    try {
      // Refresh the session first — throws AuthException if the account was
      // deleted or the session is otherwise invalid, which prevents the FK
      // violation that would occur when inserting with a stale UUID.
      await _client.auth.refreshSession();

      // Always read the user ID from the live session, never trust the
      // caller-supplied profile.id (which could be stale after account
      // deletion + re-sign-up).
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return Result.failure(const AuthFailure('Not logged in'));

      final model = UserProfileModel(
        id: userId,
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

      // upsert: inserts if no row exists yet (new users), updates otherwise.
      final data = await _client
          .from('profiles')
          .upsert(model.toJson())
          .select()
          .single();

      return Result.success(UserProfileModel.fromJson(data));
    } on AuthException catch (e) {
      // Session is invalid (account deleted, token expired, etc.)
      // Sign out so the router redirects to login with a clean state.
      await _client.auth.signOut();
      return Result.failure(AuthFailure(e.message));
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
        .map<UserProfile?>((data) {
          if (data.isEmpty) return null;
          return UserProfileModel.fromJson(data.first);
        })
        .transform(StreamTransformer<UserProfile?, UserProfile?>.fromHandlers(
          // Realtime bağlantı hatalarını null'a çevir; UI error state'e girmesin
          handleError: (_, __, sink) => sink.add(null),
        ))
        // Suppress redundant re-emits so in-progress async providers
        // (e.g. Gemini calls in natal chart) are not cancelled unnecessarily.
        .distinct((a, b) {
          if (a == null && b == null) return true;
          if (a == null || b == null) return false;
          return a.id == b.id &&
              a.sunSign == b.sunSign &&
              a.moonSign == b.moonSign &&
              a.risingSign == b.risingSign &&
              a.subscriptionTier == b.subscriptionTier;
        });
  }
}
