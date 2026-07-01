import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/di.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/confirm_email_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/astrology/presentation/screens/natal_chart_screen.dart';
import '../features/astrology/presentation/screens/birth_map_screen.dart';
import '../features/compatibility/domain/entities/compatibility_partner.dart';
import '../features/compatibility/presentation/screens/compatibility_detail_screen.dart';
import '../features/astrology/presentation/screens/daily_horoscope_screen.dart';
import '../features/compatibility/presentation/screens/compatibility_screen.dart';
import '../features/breathwork/presentation/screens/breathwork_screen.dart';
import '../features/moon/presentation/screens/moon_calendar_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/subscription/presentation/screens/paywall_screen.dart';
import '../features/stardust/presentation/screens/stardust_store_screen.dart';
import '../features/astrocartography/presentation/screens/astrocartography_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/numerology/presentation/screens/numerology_screen.dart';
import '../features/help/presentation/screens/help_screen.dart';
import '../features/legal/presentation/screens/legal_screen.dart';
import '../features/legal/legal_documents.dart';
import '../core/widgets/shell_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Converts a [Stream] into a [Listenable] so GoRouter can refresh
/// its redirect logic whenever the auth state changes.
///
/// Tracks [initialized] so the redirect can avoid acting before the first
/// auth event arrives (prevents a premature /login redirect on web refresh
/// when the Supabase session-restore event fires before this stream
/// subscribes).
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) {
      _initialized = true;
      notifyListeners();
    });
  }

  bool _initialized = false;
  bool get initialized => _initialized;

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final refreshListenable =
      _GoRouterRefreshStream(supabase.auth.onAuthStateChange);
  ref.onDispose(refreshListenable.dispose);

  // Set the initial location based on the session that Supabase already
  // restored during initialize() (which is awaited before runApp()).
  // This prevents the router from defaulting to '/' and immediately
  // redirecting an unauthenticated user to /login before the stream fires.
  final initialLocation =
      supabase.auth.currentUser != null ? '/' : '/login';

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialLocation,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final isLoggedIn = supabase.auth.currentUser != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/confirm-email';

      // Redirect away from auth screens as soon as a session is available.
      // This handles PKCE email confirmation where supabase_flutter exchanges
      // the code during initialize() — the session is set before the GoRouter
      // stream subscriber exists, so we can't rely on an auth event to trigger
      // this; instead we check currentUser directly on every redirect evaluation.
      if (isLoggedIn && isAuthRoute) return '/';

      // For protecting authenticated routes, wait for the first auth-state event
      // before redirecting. This prevents a premature /login flash on page
      // refresh while Supabase is still restoring the session asynchronously.
      if (!refreshListenable.initialized) return null;

      if (!isLoggedIn && !isAuthRoute) return '/login';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/confirm-email',
        builder: (context, state) {
          final extra = state.extra;
          final String email;
          String? password;
          if (extra is Map) {
            email = extra['email'] as String? ?? '';
            password = extra['password'] as String?;
          } else {
            email = extra as String? ?? '';
          }
          return ConfirmEmailScreen(email: email, password: password);
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/astrology',
            builder: (context, state) => const NatalChartScreen(),
          ),
          GoRoute(
            path: '/horoscope',
            builder: (context, state) => const DailyHoroscopeScreen(),
          ),
          GoRoute(
            path: '/compatibility',
            builder: (context, state) => const CompatibilityScreen(),
          ),
          GoRoute(
            path: '/breathwork',
            builder: (context, state) => const BreathworkScreen(),
          ),
          GoRoute(
            path: '/moon',
            builder: (context, state) => const MoonCalendarScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/paywall',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: '/stardust',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const StardustStoreScreen(),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/birth-map',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BirthMapScreen(),
      ),
      GoRoute(
        path: '/astrocartography',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AstrocartographyScreen(),
      ),
      GoRoute(
        path: '/numerology',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NumerologyScreen(),
      ),
      GoRoute(
        path: '/help',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: '/terms',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            const LegalScreen(docType: LegalDocType.terms),
      ),
      GoRoute(
        path: '/privacy',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            const LegalScreen(docType: LegalDocType.privacy),
      ),
      GoRoute(
        path: '/compatibility/partner',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final partner = state.extra as CompatibilityPartner?;
          if (partner == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return CompatibilityDetailScreen(partner: partner);
        },
      ),
    ],
  );
});
