import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';

/// Blocking dialog shown when a Shorebird patch has been downloaded and is
/// pending a restart.
///
/// Unlike a snackbar, this cannot be dismissed by tapping outside and offers a
/// single "OK" action. Tapping it terminates the app so that the next launch is
/// a cold start, which is when Shorebird applies the downloaded patch. The user
/// then reopens the app on the updated build.
class UpdateReadyDialog extends StatelessWidget {
  const UpdateReadyDialog({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  /// Shows the non-dismissible update-ready dialog.
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) =>
          UpdateReadyDialog(onConfirm: onConfirm),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: child,
        );
      },
    );
  }

  /// Closes the app so the pending patch is applied on the next cold start.
  ///
  /// `exit(0)` guarantees the process is terminated; relying on
  /// [SystemNavigator.pop] alone can leave the process warm in memory, in which
  /// case reopening would resume the old build without the patch.
  static Future<void> closeApp() async {
    await SystemNavigator.pop();
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final isDark = context.isDarkMode;

    final dialogBg = isDark
        ? AppColors.darkCardColor
        : theme.colorScheme.surface.withValues(alpha: 0.98);
    final dividerColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.2 : 0.12,
    );
    final textColor = isDark ? AppColors.white : AppColors.textBlack;

    return PopScope(
      canPop: false,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                    child: Column(
                      children: [
                        Text(
                          l10n.updateReadyTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.updateReadyMessage,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: textColor.withValues(alpha: 0.85),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: dividerColor),
                  GestureDetector(
                    onTap: onConfirm,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        l10n.updateReadyAction,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tealColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
