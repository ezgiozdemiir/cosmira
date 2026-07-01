import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/di.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(supabaseClientProvider));
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  // Re-run whenever auth state changes so we always stream the current user's profile.
  ref.watch(authStateProvider);
  return ref.watch(authRepositoryProvider).watchProfile();
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).signInWithApple();
    state = result.when(
      success: (_) => const AsyncData(null),
      failure: (f) => AsyncError(f.message, StackTrace.current),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).signInWithGoogle();
    state = result.when(
      success: (_) => const AsyncData(null),
      failure: (f) => AsyncError(f.message, StackTrace.current),
    );
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).signInWithEmail(email, password);
    state = result.when(
      success: (_) => const AsyncData(null),
      failure: (f) => AsyncError(f.message, StackTrace.current),
    );
  }

  // Returns true if email confirmation is required.
  Future<bool> signUpWithEmail(String email, String password, String name) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).signUpWithEmail(email, password, name);
    return result.when(
      success: (needsConfirmation) {
        state = const AsyncData(null);
        return needsConfirmation;
      },
      failure: (f) {
        state = AsyncError(f.message, StackTrace.current);
        return false;
      },
    );
  }

  Future<void> resendConfirmationEmail(String email) async {
    await ref.read(authRepositoryProvider).resendConfirmationEmail(email);
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    // Invalidate cached providers so the next user sees their own data.
    ref.invalidate(currentUserProvider);
  }
}
