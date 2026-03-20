import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../widgets/otp_verification_view.dart';
import '../../providers/change_email_otp_provider.dart';

class ChangeEmailVerifyOtpView extends StatelessWidget {
  const ChangeEmailVerifyOtpView({
    super.key,
    required this.appBarTitle,
    required this.title,
    required this.subtitle,
    required this.onVerified,
  });

  final String appBarTitle;
  final String title;
  final String subtitle;
  final Future<void> Function(BuildContext context) onVerified;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChangeEmailOtpProvider>();
    final l10n = context.l10n!;
    final theme = context.theme;
    return OtpVerificationView(
      appBarTitle: appBarTitle,
      title: title,
      subtitle: subtitle,
      otpLength: ChangeEmailOtpProvider.otpLength,
      countdownSeconds: provider.countdownSeconds,
      canResend: provider.canResend,
      hasError: provider.hasError,
      onInitialRequest: provider.requestOtp,
      onOtpChanged: provider.setOtp,
      onOtpCompleted: () => _verify(context, provider),
      onResend: provider.resendOtp,
      bottomSection: Text(
        l10n.needHelpContactSupport,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Future<void> _verify(
    BuildContext context,
    ChangeEmailOtpProvider provider,
  ) async {
    final valid = await provider.verifyOtp();
    if (!context.mounted || !valid) return;
    await onVerified(context);
  }
}
