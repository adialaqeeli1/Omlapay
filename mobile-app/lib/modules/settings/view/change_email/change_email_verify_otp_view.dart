import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../routes/app_router.dart';
import '../../../../widgets/otp_verification_view.dart';

/// Generic OTP verification screen for the change-email flow.
///
/// Used for both phone-OTP (step 1–2) and email-OTP (step 3–4).
/// The caller provides the OTP state and callbacks.
class ChangeEmailVerifyOtpView extends StatelessWidget {
  const ChangeEmailVerifyOtpView({
    super.key,
    required this.appBarTitle,
    required this.title,
    required this.subtitle,
    required this.otpLength,
    required this.countdownSeconds,
    required this.canResend,
    required this.hasError,
    required this.onInitialRequest,
    required this.onOtpChanged,
    required this.onOtpCompleted,
    required this.onResend,
    this.onBackPressed,
  });

  final String appBarTitle;
  final String title;
  final String subtitle;
  final int otpLength;
  final int countdownSeconds;
  final bool canResend;
  final bool hasError;
  final Future<void> Function() onInitialRequest;
  final void Function(String value) onOtpChanged;
  final Future<void> Function(BuildContext context) onOtpCompleted;
  final Future<void> Function() onResend;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.l10n!;
    return OtpVerificationView(
      appBarTitle: appBarTitle,
      title: title,
      subtitle: subtitle,
      onBackPressed: onBackPressed,
      otpLength: otpLength,
      countdownSeconds: countdownSeconds,
      canResend: canResend,
      hasError: hasError,
      onInitialRequest: onInitialRequest,
      onOtpChanged: onOtpChanged,
      onOtpCompleted: () => _verify(context),
      onResend: () => _resend(context),
      bottomSection: TextButton(
        onPressed: () => context.push(Routes.helpCenter),
        child: Text(
          l10n.needHelpContactSupport,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurface,
            decoration: TextDecoration.underline,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> _verify(BuildContext context) async {
    try {
      await onOtpCompleted(context);
    } on AppException catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(context, e.localizedMessage(context.l10n));
      }
    }
  }

  Future<void> _resend(BuildContext context) async {
    try {
      await onResend();
    } on AppException catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(context, e.localizedMessage(context.l10n));
      }
    }
  }
}
