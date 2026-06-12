import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';

/// Blocking dialog shown while a Shorebird patch is being downloaded and until
/// it is ready to install.
///
/// It cannot be dismissed by tapping outside or with the back button, so all
/// navigation is blocked for the duration of the update. Tapping "OK" waits for
/// the download ([whenReady]) to finish — showing a spinner if it is still in
/// progress — and then terminates the app so the next launch is a cold start,
/// which is when Shorebird applies the downloaded patch.
///
/// If the download fails, [whenReady] completes with an error and the dialog
/// dismisses itself so the user is not left on a blocking screen.
class UpdateReadyDialog extends StatefulWidget {
  const UpdateReadyDialog({super.key, required this.whenReady});

  /// Completes when the patch has finished downloading and is ready to install,
  /// or with an error if the download fails.
  final Future<void> whenReady;

  /// Shows the non-dismissible update dialog.
  static Future<void> show(
    BuildContext context, {
    required Future<void> whenReady,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) =>
          UpdateReadyDialog(whenReady: whenReady),
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
  State<UpdateReadyDialog> createState() => _UpdateReadyDialogState();
}

class _UpdateReadyDialogState extends State<UpdateReadyDialog> {
  /// True once the download has finished and the patch is ready to install.
  bool _isReady = false;

  /// True while the user has confirmed but the download is still finishing.
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _awaitReady();
  }

  Future<void> _awaitReady() async {
    try {
      await widget.whenReady;
      if (!mounted) return;
      setState(() => _isReady = true);
      // If the user already tapped "OK" while downloading, close now.
      if (_isClosing) await UpdateReadyDialog.closeApp();
    } catch (_) {
      // Download failed: release the blocking dialog so navigation is restored.
      if (mounted) Navigator.of(context).maybePop();
    }
  }

  Future<void> _onConfirm() async {
    if (_isClosing) return;
    if (_isReady) {
      await UpdateReadyDialog.closeApp();
      return;
    }
    // Still downloading: show a spinner; _awaitReady() closes once it finishes.
    setState(() => _isClosing = true);
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
                    onTap: () {
                      Navigator.pop(context);
                      _onConfirm();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: _isClosing
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.tealColor,
                                ),
                              ),
                            )
                          : Text(
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
