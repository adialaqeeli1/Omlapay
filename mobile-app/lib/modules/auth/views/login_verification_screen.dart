import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/extentions/string_extensions.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common_auth_agreement_text.dart';
import '../../../widgets/otp_verification_view.dart';
import '../providers/login_provider.dart';
import '../providers/login_verification_provider.dart';

/// OTP screen for the new hard-login flow. Reuses [OtpVerificationView] for
/// presentation; backed by [LoginVerificationProvider] which hits the
/// `/v1/auth/login/{send-otp,verify-otp,resend-otp}` endpoints.
///
/// On successful verification, the captured `otpVerificationToken` is passed
/// to the passcode screen via route extras.
class LoginVerificationScreen extends StatelessWidget {
  const LoginVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoginVerificationProvider>();
    final l10n = context.l10n!;
    final theme = context.theme;

    return OtpVerificationView(
      appBarTitle: '',
      title: l10n.verifyYourAccount,
      subtitle: l10n.verificationCodeSentViaSmsTo(
        provider.formattedPhoneForDisplay.ltrPhoneNumber,
      ),
      otpLength: LoginVerificationProvider.otpLength,
      countdownSeconds: provider.countdownSeconds,
      canResend: provider.canResend,
      hasError: provider.hasError,
      onInitialRequest: provider.requestOtp,
      onOtpChanged: provider.setOtpFromString,
      onOtpCompleted: () => _verifyOtp(context, provider),
      onResend: () async {
        try {
          final message = await provider.resendOtp();
          if (!context.mounted) return;
          SnackbarHelper.showSuccess(
            context,
            message ?? l10n.verificationCodeResentSuccess,
          );
        } catch (e) {
          if (!context.mounted) return;
          SnackbarHelper.showError(context, e.toString());
        }
      },
      showProgress: false,
      titleStyle: GoogleFonts.poppinsTextTheme().displaySmall?.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.24,
        color: theme.colorScheme.onSurface,
      ),
      bottomSection: const CommonAuthAgreementText(),
    );
  }

  Future<void> _verifyOtp(
    BuildContext context,
    LoginVerificationProvider provider,
  ) async {
    try {
      final isValid = await provider.verifyOtp();
      if (!context.mounted || !isValid) return;
      final token = provider.otpVerificationToken;
      if (token == null || token.isEmpty) {
        SnackbarHelper.showError(context, context.l10n!.unknownError);
        return;
      }
      context.push(
        Routes.enterOrSetPasscode,
        extra: {
          LoginProvider.extraModeKey: LoginProvider.modeHardLogin,
          LoginProvider.extraCountryCodeKey: provider.countryCode,
          LoginProvider.extraPhoneNumberKey: provider.phoneNumber,
          LoginProvider.extraOtpVerificationTokenKey: token,
        },
      );
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(context, e.toString());
      }
    }
  }
}
