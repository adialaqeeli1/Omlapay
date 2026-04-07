import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/theme.dart';
import 'core/services/storage_helper.dart';
import 'providers/auth_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/coins_prices_provider.dart';
import 'providers/global_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/wallets_provider.dart';
import 'core/services/coins_prices_stream_service.dart';
import 'core/services/coins_service.dart';
import 'core/l10n/app_localizations.dart';
import 'routes/app_router.dart';
import 'widgets/offline_view.dart';

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
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => ConnectivityProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, LocaleProvider>(
          create: (_) => LocaleProvider(),
          update: (_, auth, locale) =>
              (locale ?? LocaleProvider())
                ..onAuthChanged(auth.state.isAuthenticated),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ThemeProvider>(
          create: (_) => ThemeProvider(),
          update: (_, auth, theme) =>
              (theme ?? ThemeProvider())
                ..onAuthChanged(auth.state.isAuthenticated),
        ),
        ChangeNotifierProxyProvider<AuthProvider, GlobalProvider>(
          create: (_) => GlobalProvider(),
          update: (_, auth, global) =>
              (global ?? GlobalProvider())
                ..onAuthChanged(auth.state.isAuthenticated),
        ),
        ChangeNotifierProvider<CoinsPricesProvider>(
          create: (context) {
            final coinsService = CoinsService();
            return CoinsPricesProvider(
              context.read<GlobalProvider>(),
              CoinsPricesStreamService(coinsService),
              coinsService,
            );
          },
        ),
        ChangeNotifierProvider<WalletsProvider>(
          create: (context) => WalletsProvider(context.read<GlobalProvider>()),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, child) =>
            MaterialApp.router(
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context)!.appTitle,
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
                CountryLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) {
                final connectivity = context.watch<ConnectivityProvider>();
                // Don't block until the initial check is done.
                if (connectivity.isInitialized && !connectivity.isConnected) {
                  return OfflineView(
                    onRetry: () => connectivity.checkConnectivity(),
                  );
                }
                return child ?? const SizedBox.shrink();
              },
            ),
      ),
    );
  }
}
