import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../routes/app_router.dart';
import '../../../../widgets/otp_verification_view.dart';
import '../provider/send_provider.dart';

class SendVerificationView extends StatelessWidget {
  const SendVerificationView({super.key});

  static const int _otpLength = 6;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SendProvider>();
    final l10n = context.l10n!;
    final theme = context.theme;

    return OtpVerificationView(
      appBarTitle: '',
      title: l10n.verifyAccount,
      subtitle: l10n.verifyYourPhoneNumber,
      otpLength: _otpLength,
      countdownSeconds: provider.otpCountdown,
      canResend: provider.canResendOtp && !provider.isOtpSubmitting,
      hasError: provider.hasOtpError,
      onInitialRequest: () async {},
      onOtpChanged: provider.setOtpInput,
      onOtpCompleted: () => _verify(context, provider),
      onResend: () => _resend(context, provider),
      bottomSection: Text(
        l10n.needHelpContactSupport,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Future<void> _verify(BuildContext context, SendProvider provider) async {
    final otp = provider.otpInput;
    if (otp.length != _otpLength) return;
    final l10n = context.l10n!;
    try {
      final success = await provider.confirmSendWithOtp(otp);
      if (!context.mounted) return;
      if (!success) return;
      final message = provider.confirmMessage;
      if (message != null && message.isNotEmpty) {
        SnackbarHelper.showSuccess(context, message);
      }
      context.go(Routes.sendSuccess, extra: provider);
    } on AppException catch (e) {
      if (!context.mounted) return;
      SnackbarHelper.showError(context, e.localizedMessage(context.l10n));
    } catch (_) {
      if (!context.mounted) return;
      SnackbarHelper.showError(context, l10n.unknownError);
    }
  }

  Future<void> _resend(BuildContext context, SendProvider provider) async {
    final l10n = context.l10n!;
    try {
      final message = await provider.resendSendOtp();
      if (!context.mounted) return;
      if (message == null) return; // pre-flight blocked (no token / cooldown)
      if (message.isNotEmpty) {
        SnackbarHelper.showSuccess(context, message);
      }
    } on AppException catch (e) {
      if (!context.mounted) return;
      SnackbarHelper.showError(context, e.localizedMessage(context.l10n));
    } catch (_) {
      if (!context.mounted) return;
      SnackbarHelper.showError(context, l10n.unknownError);
    }
  }
}
