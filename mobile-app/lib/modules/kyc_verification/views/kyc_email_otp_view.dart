import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/utils/app_exception.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../widgets/otp_verification_view.dart';
import '../providers/kyc_email_provider.dart';

class KycEmailOtpView extends StatelessWidget {
  const KycEmailOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final provider = context.watch<KycEmailProvider>();

    return OtpVerificationView(
      appBarTitle: l10n.kycVerifyEmail,
      title: l10n.kycVerifyEmailTitle,
      subtitle: l10n.kycVerifyEmailSubtitle(provider.email.trim()),
      otpLength: KycEmailProvider.otpLength,
      countdownSeconds: provider.countdownSeconds,
      canResend: provider.canResend,
      hasError: provider.hasError,
      onInitialRequest: () async {
        // OTP was already requested when navigating here from email entry
      },
      onOtpChanged: provider.setOtp,
      onOtpCompleted: () => _onOtpCompleted(context, provider),
      onResend: () => _onResend(context, provider),
    );
  }

  Future<void> _onOtpCompleted(
    BuildContext context,
    KycEmailProvider provider,
  ) async {
    try {
      final valid = await provider.verifyOtp();
      if (!context.mounted || !valid) return;
      // Pop OTP view, returning true to email entry view
      context.pop(true);
    } on AppException catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(context, e.localizedMessage(context.l10n));
      }
    }
  }

  Future<void> _onResend(
    BuildContext context,
    KycEmailProvider provider,
  ) async {
    try {
      await provider.resendOtp();
    } on AppException catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(context, e.localizedMessage(context.l10n));
      }
    }
  }
}
