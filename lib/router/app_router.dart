import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/di.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/astrology/presentation/screens/natal_chart_screen.dart';
import '../features/astrology/presentation/screens/daily_horoscope_screen.dart';
import '../features/compatibility/presentation/screens/compatibility_screen.dart';
import '../features/breathwork/presentation/screens/breathwork_screen.dart';
import '../features/moon/presentation/screens/moon_calendar_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/subscription/presentation/screens/paywall_screen.dart';
import '../features/stardust/presentation/screens/stardust_store_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../core/widgets/shell_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Converts a [Stream] into a [Listenable] so GoRouter can refresh
/// its redirect logic whenever the auth state changes.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

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

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final isLoggedIn = supabase.auth.currentUser != null;
      final isAuthRoute = state.matchedLocation == '/login';
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
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
    ],
  );
});
