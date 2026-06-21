import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/env.dart';
import 'core/providers/language_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/web_utils_stub.dart'
    if (dart.library.js_interop) 'core/utils/web_utils_html.dart';
import 'router/app_router.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
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
      authFlowType: AuthFlowType.pkce,
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
