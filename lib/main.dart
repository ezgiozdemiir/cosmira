import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/env.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/web_utils_stub.dart'
    if (dart.library.js_interop) 'core/utils/web_utils_html.dart';
import 'router/app_router.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

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
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // If this page loaded inside our OAuth popup, Supabase has already processed
  // the auth code and written the session to localStorage. Close the popup so
  // the parent tab can reload and pick up the session.
  if (isInPopup) {
    closePopup();
    return;
  }

  runApp(const ProviderScope(child: CosmiraApp()));
}

class CosmiraApp extends ConsumerWidget {
  const CosmiraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Cosmira',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
