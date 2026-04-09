import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../widgets/otp_verification_view.dart';
import '../../providers/change_phone_current_otp_provider.dart';

class ChangePhoneVerifyCurrentOtpView extends StatelessWidget {
  const ChangePhoneVerifyCurrentOtpView({
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
    final provider = context.watch<ChangePhoneCurrentOtpProvider>();
    final l10n = context.l10n!;
    final theme = context.theme;
    return OtpVerificationView(
      appBarTitle: appBarTitle,
      title: title,
      subtitle: subtitle,
      otpLength: ChangePhoneCurrentOtpProvider.otpLength,
      countdownSeconds: provider.countdownSeconds,
      canResend: provider.canResend,
      hasError: provider.hasError,
      onInitialRequest: () => _safeRequestOtp(context, provider),
      onOtpChanged: provider.setOtp,
      onOtpCompleted: () => _verify(context, provider),
      onResend: () => _safeResend(context, provider),
      bottomSection: Text(
        l10n.needHelpContactSupport,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Future<void> _safeRequestOtp(
    BuildContext context,
    ChangePhoneCurrentOtpProvider provider,
  ) async {
    final l10n = context.l10n!;
    try {
      await provider.requestOtp();
    } on AppException catch (e) {
      if (!context.mounted) return;
      SnackbarHelper.showError(context, e.localizedMessage(context.l10n));
    } catch (_) {
      if (!context.mounted) return;
      SnackbarHelper.showError(context, l10n.unknownError);
    }
  }

  Future<void> _safeResend(
    BuildContext context,
    ChangePhoneCurrentOtpProvider provider,
  ) async {
    final l10n = context.l10n!;
    try {
      await provider.resendOtp();
    } on AppException catch (e) {
      if (!context.mounted) return;
      SnackbarHelper.showError(context, e.localizedMessage(context.l10n));
    } catch (_) {
      if (!context.mounted) return;
      SnackbarHelper.showError(context, l10n.unknownError);
    }
  }

  Future<void> _verify(
    BuildContext context,
    ChangePhoneCurrentOtpProvider provider,
  ) async {
    final valid = await provider.verifyOtp();
    if (!context.mounted) return;
    if (!valid) {
      final key = provider.verifyErrorKey;
      if (key != null && key.isNotEmpty) {
        SnackbarHelper.showError(
          context,
          AppException.resolveErrorKey(context.l10n!, key) ?? context.l10n!.unknownError,
        );
      }
      return;
    }
    await onVerified(context);
  }
}
