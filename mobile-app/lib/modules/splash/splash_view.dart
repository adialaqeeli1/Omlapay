import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../core/extentions/context_extensions.dart';
import '../../core/services/storage_helper.dart';
import '../../core/constants/constants.dart';
import '../../modules/auth/providers/login_provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen();
      }
    });

    controller.forward();
  }

  /// Navigates to the appropriate screen based on onboarding completion and auth status
  void _navigateToNextScreen() {
    final bool isOnboardingCompleted =
        StorageService.getBool(AppConstants.onboardingCompletedKey) ?? false;

    if (!isOnboardingCompleted) {
      GoRouter.of(context).go(Routes.onboarding);
    } else {
      final isLoggedIn = context.read<AuthProvider>().state.isAuthenticated;
      if (isLoggedIn) {
        GoRouter.of(context).go(
          Routes.enterOrSetPasscode,
          extra: {LoginProvider.extraModeKey: LoginProvider.modeSoftLogin},
        );
      } else {
        GoRouter.of(context).go(Routes.home);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
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
