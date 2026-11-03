import 'package:flutter/material.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/theme/theme.dart';

/// Dialog shown when a contact does not have an Omlapay account.
///
/// Matches the [PermissionDialog] visual style — dark card in dark mode,
/// light surface in light mode, with two bottom action buttons split by a divider.
///
/// Returns `true` when the user taps **Invite**, `false` on **Cancel**.
class SendInvitationDialog extends StatelessWidget {
  const SendInvitationDialog({super.key});

  static const double _borderRadius = 24;
  static const double _horizontalPadding = 24;
  static const double _verticalPadding = 20;
  static const double _buttonHeight = 52;

  /// Dark card fill when [Brightness.dark] (matches PermissionDialog).
  static const Color _darkDialogBackground = Color(0xFF1A1A1A);

  /// Shows the dialog and returns `true` for Invite, `false` for Cancel.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SendInvitationDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
          border: isDark ? null : Border.all(color: dividerColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title + Message + Note
            Padding(
              padding: EdgeInsets.fromLTRB(
                _horizontalPadding,
                _verticalPadding + 8,
                _horizontalPadding,
                _verticalPadding,
              ),
              child: Column(
                children: [
                  Text(
                    l10n.sendInvitationDialogTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: titleColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.sendInvitationDialogMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: messageColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.sendInvitationDialogNote,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.tealColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Divider
            Divider(height: 1, thickness: 1, color: dividerColor),

            // Buttons
            IntrinsicHeight(
              child: Row(
                children: [
                  // Cancel
                  Expanded(
                    child: _DialogButton(
                      label: l10n.cancel,
                      textColor: secondaryActionColor,
                      borderRadius: const BorderRadiusDirectional.only(
                        bottomStart: Radius.circular(_borderRadius),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  Container(width: 1, color: dividerColor),
                  // Invite
                  Expanded(
                    child: _DialogButton(
                      label: l10n.sendInvitationInviteButton,
                      textColor: AppColors.tealColor,
                      fontWeight: FontWeight.w600,
                      borderRadius: const BorderRadiusDirectional.only(
                        bottomEnd: Radius.circular(_borderRadius),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
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
          height: SendInvitationDialog._buttonHeight,
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
