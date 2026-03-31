import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../providers/auth_provider.dart';
import '../providers/login_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/otp_verification_view.dart';
import '../providers/verification_provider.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key, this.showRegistrationProgress = true});

  /// When false (e.g. change passcode → SMS step), hides the 4-step registration indicator.
  final bool showRegistrationProgress;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VerificationProvider>();
    final l10n = context.l10n!;
    final theme = context.theme;
    return OtpVerificationView(
      appBarTitle: '',
      title: l10n.verifyYourAccount,
      subtitle: l10n.verificationCodeSentViaSmsTo(
        provider.formattedPhoneForDisplay,
      ),
      otpLength: VerificationProvider.otpLength,
      countdownSeconds: provider.countdownSeconds,
      canResend: provider.canResend,
      hasError: false,
      onInitialRequest: provider.requestOtp,
      onOtpChanged: provider.setOtpFromString,
      onOtpCompleted: () => _verifyOtp(provider),
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
      showProgress: widget.showRegistrationProgress,
      totalProgressSteps: 4,
      activeProgressSteps: 2,
      titleStyle: GoogleFonts.poppinsTextTheme().displaySmall?.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.24,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Future<void> _verifyOtp(VerificationProvider provider) async {
    try {
      final l10n = context.l10n!;
      final isValid = await provider.verifyOtp();
      if (!mounted || !isValid) {
        return;
      }

      final isChangePasscodePurpose =
          provider.verificationPurpose ==
          LoginProvider.purposeChangePasscode;
      final hasPasscodePayload = provider.hasChangePasscodePayload;
      final isChangePasscodeFlow =
          isChangePasscodePurpose || hasPasscodePayload;

      if (isChangePasscodeFlow) {
        if (!hasPasscodePayload) {
          SnackbarHelper.showError(context, l10n.unknownError);
          return;
        }
        final current = provider.changePasscodeCurrent!;
        final next = provider.changePasscodeNew!;
        await context.read<AuthProvider>().changePasscodeAndRefreshSession(
          currentPasscode: current,
          newPasscode: next,
          confirmPasscode: next,
          countryCode: provider.countryCode,
          mobileNumber: provider.phoneNumber,
        );
        if (!mounted) {
          return;
        }
        context.go(Routes.changePasscodeSuccess);
        return;
      }

      context.go(
        Routes.enterOrSetPasscode,
        extra: {
          LoginProvider.extraModeKey: LoginProvider.modeRegister,
          LoginProvider.extraCountryCodeKey: provider.countryCode,
          LoginProvider.extraPhoneNumberKey: provider.phoneNumber,
          if (provider.registrationToken != null)
            LoginProvider.extraRegistrationTokenKey: provider.registrationToken,
        },
      );
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, e.toString());
      }
    }
  }
}
