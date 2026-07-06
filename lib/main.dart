import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:ui' show PlatformDispatcher;
import 'config/env.dart';
import 'firebase_options.dart';
import 'core/providers/language_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/web_utils_stub.dart'
    if (dart.library.js_interop) 'core/utils/web_utils_html.dart';
import 'features/notifications/domain/services/push_notification_service.dart';
import 'features/notifications/presentation/providers/push_token_sync_provider.dart';
import 'router/app_router.dart';

// Runs in a separate isolate on Android when a push arrives while the app is
// backgrounded/terminated — must be a top-level function, and must init
// Firebase itself since it doesn't share the main isolate's setup.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase + Crashlytics must come first so errors in later init steps are captured.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await PushNotificationService.instance.initialize();

  if (kIsWeb) usePathUrlStrategy();

  await EasyLocalization.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await Hive.initFlutter();

  await Supabase.initialize(
    url: Env.supabaseUrl.isNotEmpty
        ? Env.supabaseUrl
        : 'https://placeholder.supabase.co',
    anonKey: Env.supabaseAnonKey.isNotEmpty
        ? Env.supabaseAnonKey
        : 'placeholder',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: kIsWeb ? AuthFlowType.implicit : AuthFlowType.pkce,
    ),
  );

  if (isInPopup) {
    closePopup();
    return;
  }

  final savedLang = await LanguageNotifier.loadSaved();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('tr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: Locale(savedLang),
      saveLocale: false,
      child: ProviderScope(
        overrides: [
          languageCodeProvider.overrideWith(
            (ref) => LanguageNotifier()..state = savedLang,
          ),
        ],
        child: const CosmiraApp(),
      ),
    ),
  );
}

class CosmiraApp extends ConsumerWidget {
  const CosmiraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    ref.watch(pushTokenSyncProvider);

    return MaterialApp.router(
      title: 'Cosmira',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
