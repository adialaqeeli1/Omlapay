import 'package:flutter/material.dart';

import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';

/// A dark-themed dialog for invalid QR code errors.
///
/// Matches the OmlaPay design: "Invalid QR code" message with
/// Cancel and Try Again actions.
class InvalidQrCodeDialog extends StatelessWidget {
  const InvalidQrCodeDialog({
    super.key,
    required this.onCancel,
    required this.onTryAgain,
    this.message,
  });

  final VoidCallback onCancel;
  final VoidCallback onTryAgain;
  final String? message;

  static const Color _dialogBackground = Color(0xFF1C1C1E);
  static const double _borderRadius = 24;
  static const double _horizontalPadding = 24;
  static const double _verticalPadding = 20;
  static const double _buttonHeight = 52;

  /// Shows the invalid QR code dialog.
  static Future<bool?> show(
    BuildContext context, {
    String? message,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => InvalidQrCodeDialog(
        message: message,
        onCancel: () => Navigator.of(context).pop(false),
        onTryAgain: () => Navigator.of(context).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final resolvedMessage =
        message ?? l10n?.invalidQrCode ?? 'Invalid QR code';

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
              child: Center(
                child: Text(
                  resolvedMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
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
                      label: l10n?.cancel ?? 'Cancel',
                      textColor: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(_borderRadius),
                      ),
                      onPressed: onCancel,
                    ),
                  ),
                  Container(
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  Expanded(
                    child: _DialogButton(
                      label: l10n?.tryAgain ?? 'Try Again',
                      textColor: AppColors.tealColor,
                      fontWeight: FontWeight.w600,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(_borderRadius),
                      ),
                      onPressed: onTryAgain,
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
          height: InvalidQrCodeDialog._buttonHeight,
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
