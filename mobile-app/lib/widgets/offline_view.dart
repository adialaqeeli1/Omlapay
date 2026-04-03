import 'package:flutter/material.dart';

import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';
import 'common_button.dart';

/// Full-screen offline placeholder matching the Omlapay design.
class OfflineView extends StatelessWidget {
  const OfflineView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final isDark = context.isDarkMode;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // App logo / title
              Text(
                l10n.appTitle,
                style: context.textTheme.headlineMedium?.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const Spacer(),
              // Wifi-off icon
              Icon(
                Icons.wifi_off_rounded,
                size: 64,
                color: isDark ? AppColors.textGrey : AppColors.textLightGrey,
              ),
              const SizedBox(height: 24),
              // "You are offline" text
              Text(
                l10n.youAreOffline,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textWhite : AppColors.textBlack,
                ),
              ),
              const Spacer(),
              // "Try again" button
              Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: CommonButton(onPressed: onRetry, title: l10n.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
