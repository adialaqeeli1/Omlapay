import 'package:flutter/material.dart';

import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';

/// A custom dark-themed permission dialog matching the OmlaPay design.
///
/// Displays a rationale for camera access with "Do not allow" and "Allow"
/// actions. Use as a pre-request or replacement for the system permission UI.
class CameraPermissionDialog extends StatelessWidget {
  const CameraPermissionDialog({
    super.key,
    required this.onDoNotAllow,
    this.onAllow,
    this.onOpenSettings,
    this.title,
    this.message,
  }) : assert(
         (onAllow != null) != (onOpenSettings != null),
         'Provide either onAllow or onOpenSettings',
       );

  final VoidCallback? onAllow;
  final VoidCallback? onOpenSettings;
  final VoidCallback onDoNotAllow;
  final String? title;
  final String? message;

  bool get _useOpenSettings => onOpenSettings != null;

  static const Color _dialogBackground = Color(0xFF1A1A1A);
  static const double _borderRadius = 24;
  static const double _horizontalPadding = 24;
  static const double _verticalPadding = 20;
  static const double _buttonHeight = 52;

  /// Shows the camera permission dialog with Allow action.
  static Future<bool?> show(BuildContext context, {String? title, String? message}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CameraPermissionDialog(
        title: title,
        message: message,
        onAllow: () => Navigator.of(context).pop(true),
        onDoNotAllow: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appName = l10n?.appTitle ?? 'OmlaPay';
    final resolvedTitle = title ??
        (l10n != null ? l10n.cameraPermissionDialogTitle(appName) : 'OmlaPay wants to access the camera');
    final resolvedMessage = message ??
        l10n?.cameraPermissionDialogMessage ??
        'We need your permission to access the camera to be able to scan the codes';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        decoration: BoxDecoration(
          color: _dialogBackground,
          borderRadius: BorderRadius.circular(_borderRadius),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    resolvedMessage,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
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
              color: Colors.white.withValues(alpha: 0.12),
            ),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      label: l10n?.doNotAllow ?? 'Do not allow',
                      textColor: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(_borderRadius),
                      ),
                      onPressed: onDoNotAllow,
                    ),
                  ),
                  Container(
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  Expanded(
                    child: _DialogButton(
                      label: _useOpenSettings
                          ? (l10n?.openSettings ?? 'Open Settings')
                          : (l10n?.allowCamera ?? 'Allow'),
                      textColor: AppColors.tealColor,
                      fontWeight: FontWeight.w600,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(_borderRadius),
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
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius,
        child: Container(
          height: CameraPermissionDialog._buttonHeight,
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
