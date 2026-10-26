import 'package:flutter/material.dart';

import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';

/// Logout confirmation alert matching Figma design.
/// Uses Dissolve (Fade) animation with spring-like curve.
class LogoutAlertDialog extends StatelessWidget {
  const LogoutAlertDialog({
    super.key,
    required this.onCancel,
    required this.onLogout,
  });

  final VoidCallback onCancel;
  final VoidCallback onLogout;

  /// Shows the logout confirmation dialog with Dissolve (Fade) animation
  /// and spring-like feel (mass: 1, stiffness: 100, damping: 15).
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onLogout,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) =>
          LogoutAlertDialog(
            onCancel: () => Navigator.of(context).pop(),
            onLogout: () {
              Navigator.of(context).pop();
              onLogout();
            },
          ),
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

    return Center(
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
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                  child: Column(
                    children: [
                      Text(
                        l10n.readyToLogOut,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // const SizedBox(height: 12),
                      // Text(
                      //   l10n.logoutDialogMessage,
                      //   style: theme.textTheme.bodyMedium?.copyWith(
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.w400,
                      //     color: textColor.withValues(alpha: 0.85),
                      //     height: 1.4,
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
                    ],
                  ),
                ),
                Divider(height: 1, color: dividerColor),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onCancel,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              l10n.cancel,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1, color: dividerColor),
                      Expanded(
                        child: GestureDetector(
                          onTap: onLogout,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              l10n.logout,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.logoutDestructiveColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
