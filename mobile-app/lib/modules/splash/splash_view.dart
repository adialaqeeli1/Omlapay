import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../core/extentions/context_extensions.dart';
import '../../core/services/push_notification_service.dart';
import '../../core/services/storage_helper.dart';
import '../../core/constants/constants.dart';
import '../../modules/auth/providers/login_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/code_push_provider.dart';
import '../../routes/app_router.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  bool _navigationStarted = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    controller.addStatusListener((status) {
      if (!mounted || _navigationStarted) return;
      if (status == AnimationStatus.completed) {
        _navigationStarted = true;
        _navigateToNextScreen();
      }
    });

    controller.forward();
  }

  /// Navigates to the appropriate screen based on onboarding completion and auth status.
  ///
  /// Captures provider/router references up-front so we never look up ancestors
  /// after the splash widget has been deactivated (e.g. when an in-flight 401
  /// triggers a tree rebuild while the animation is finishing).
  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;
    final router = GoRouter.of(context);
    final authProvider = context.read<AuthProvider>();
    final codePush = context.read<CodePushProvider>();

    // If a Shorebird patch is downloading or ready, the blocking update dialog
    // takes over and closes the app, so hold on the splash instead of routing
    // away. Wait for the initial check to settle first: on no update / a failed
    // download this resolves and we navigate normally. No-op when Shorebird is
    // unavailable (debug builds), keeping startup unchanged in development.
    if (codePush.isShorebirdAvailable) {
      await codePush.initialCheckSettled;
      if (!mounted) return;
      if (codePush.isDownloading || codePush.isUpdateReadyToInstall) return;
    }

    final bool isOnboardingCompleted =
        StorageService.getBool(AppConstants.onboardingCompletedKey) ?? false;

    if (!isOnboardingCompleted) {
      router.go(Routes.onboarding);
      return;
    }

    final isLoggedIn = authProvider.state.isAuthenticated;
    if (!isLoggedIn) {
      router.go(Routes.home);
      return;
    }

    final isSessionValid = await authProvider.validateSession();
    if (!mounted) return;

    if (!isSessionValid) {
      await authProvider.logout();
      if (!mounted) return;
      router.go(Routes.loginOrRegister);
      return;
    }

    // Register FCM push-notification device token with backend (fire-and-forget).
    unawaited(PushNotificationService.instance.registerCurrentDevice());

    router.go(
      Routes.enterOrSetPasscode,
      extra: {LoginProvider.extraModeKey: LoginProvider.modeSoftLogin},
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String splashAnimationPath =
        Localizations.localeOf(context).languageCode == 'ar'
        ? (context.isDarkMode
              ? 'assets/animations/splash_animation_dark_ar.json'
              : 'assets/animations/splash_animation_light_ar.json')
        : (context.isDarkMode
              ? 'assets/animations/splash_animation_dark.json'
              : 'assets/animations/splash_animation_light.json');

    return Scaffold(
      body: Center(
        child: Lottie.asset(
          splashAnimationPath,
          repeat: false,
          controller: controller,
        ),
      ),
    );
  }
}
