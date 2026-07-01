import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

// Watches the raw auth stream so currentUserProvider rebuilds on sign-in/out.
final _authChangeProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  ref.watch(_authChangeProvider); // re-run whenever auth state changes
  return ref.watch(supabaseClientProvider).auth.currentUser;
});
