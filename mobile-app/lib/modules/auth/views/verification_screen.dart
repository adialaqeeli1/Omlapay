import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
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
      onResend: provider.resendOtp,
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
    final isValid = await provider.verifyOtp();
    if (!mounted || !isValid) {
      return;
    }

    final extra = GoRouterState.of(context).extra;
    if (extra is Map<String, dynamic> &&
        extra[LoginProvider.extraVerificationPurposeKey] ==
            LoginProvider.purposeChangePasscode) {
      final newPasscode =
          extra[LoginProvider.extraPendingPasscodeKey] as String?;
      if (newPasscode == null || newPasscode.length != 6) {
        return;
      }
      final applied = await context.read<AuthProvider>().setPasscode(
        provider.phoneNumber,
        provider.countryCode,
        newPasscode,
      );
      if (!mounted || !applied) {
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
      },
    );
  }
}
