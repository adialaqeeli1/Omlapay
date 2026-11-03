import 'package:flutter/material.dart';

import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';

/// Custom permission rationale dialog; follows app light/dark theme.
///
/// Displays rationale with "Do not allow" and "Allow" (or "Open settings"
/// when permanently denied). Shown before or around the system permission flow.
///
/// Used for camera, contacts, and any other permission that needs a rationale.
class PermissionDialog extends StatelessWidget {
  const PermissionDialog({
    super.key,
    required this.onDoNotAllow,
    this.onAllow,
    this.onOpenSettings,
    this.title,
    this.message,
    this.allowLabel,
  }) : assert(
         (onAllow != null) != (onOpenSettings != null),
         'Provide either onAllow or onOpenSettings',
       );

  final VoidCallback? onAllow;
  final VoidCallback? onOpenSettings;
  final VoidCallback onDoNotAllow;
  final String? title;
  final String? message;
  final String? allowLabel;

  bool get _useOpenSettings => onOpenSettings != null;

  static const double _borderRadius = 24;
  static const double _horizontalPadding = 24;
  static const double _verticalPadding = 20;
  static const double _buttonHeight = 52;

  /// Dark card fill when [Brightness.dark] (matches prior OmlaPay scanner UI).
  static const Color _darkDialogBackground = Color(0xFF1A1A1A);

  /// Shows the permission dialog with Allow action.
  static Future<bool?> show(
    BuildContext context, {
    String? title,
    String? message,
    String? allowLabel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialog(
        title: title,
        message: message,
        allowLabel: allowLabel,
        onAllow: () => Navigator.of(context).pop(true),
        onDoNotAllow: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final appName = l10n.appTitle;
    final resolvedTitle =
        title ?? l10n.cameraPermissionDialogTitle(appName);
    final resolvedMessage =
        message ?? l10n.cameraPermissionDialogMessage;

    final backgroundColor =
        isDark ? _darkDialogBackground : colorScheme.surface;
    final dividerColor = colorScheme.outlineVariant;
    final titleColor = colorScheme.onSurface;
    final messageColor = colorScheme.onSurfaceVariant;
    final secondaryActionColor = colorScheme.onSurface;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(_borderRadius),
          border: isDark
              ? null
              : Border.all(color: dividerColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _horizontalPadding,
                _verticalPadding + 8,
                _horizontalPadding,
                _verticalPadding,
              ),
              child: Column(
                children: [
                  Text(
                    resolvedTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: titleColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    resolvedMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: messageColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: dividerColor,
            ),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      label: l10n.doNotAllow,
                      textColor: secondaryActionColor,
                      borderRadius: const BorderRadiusDirectional.only(
                        bottomStart: Radius.circular(_borderRadius),
                      ),
                      onPressed: onDoNotAllow,
                    ),
                  ),
                  Container(
                    width: 1,
                    color: dividerColor,
                  ),
                  Expanded(
                    child: _DialogButton(
                      label: _useOpenSettings
                          ? l10n.openSettings
                          : allowLabel ?? l10n.allowCamera,
                      textColor: AppColors.tealColor,
                      fontWeight: FontWeight.w600,
                      borderRadius: const BorderRadiusDirectional.only(
                        bottomEnd: Radius.circular(_borderRadius),
                      ),
                      onPressed: _useOpenSettings ? onOpenSettings! : onAllow!,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.textColor,
    required this.onPressed,
    this.fontWeight = FontWeight.w400,
    this.borderRadius,
  });

  final String label;
  final Color textColor;
  final VoidCallback onPressed;
  final FontWeight fontWeight;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final resolvedRadius = borderRadius?.resolve(Directionality.of(context));
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: resolvedRadius,
        child: Container(
          height: PermissionDialog._buttonHeight,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: fontWeight,
            ),
          ),
        ),
      ),
    );
  }
}
