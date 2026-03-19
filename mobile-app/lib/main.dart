import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/theme.dart';
import 'core/services/storage_helper.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/global_provider.dart';
import 'providers/notification_provider.dart';
import 'core/l10n/app_localizations.dart';
import 'routes/app_router.dart';

Future<void> _initializeApp() async {
  // Initialize storage (non-blocking)
  await StorageService.init().catchError((error) {
    debugPrint("Error initializing storage: $error");
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize everything in background (blocking)
  await _initializeApp();

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<GlobalProvider>(create: (_) => GlobalProvider()),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, child) =>
            MaterialApp.router(
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context)?.appTitle ?? 'OmlaPay',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              // themeMode: ThemeMode.light,
              routerConfig: AppRouter.router,
              debugShowCheckedModeBanner: false,
              locale: localeProvider.locale,
              // locale: Locale('en'),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            ),
      ),
    );
  }
}
