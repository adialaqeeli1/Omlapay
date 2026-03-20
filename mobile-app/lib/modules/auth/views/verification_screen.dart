import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../providers/auth_provider.dart';
import '../providers/login_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common_back_button.dart';
import '../providers/verification_provider.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({
    super.key,
    this.showRegistrationProgress = true,
  });

  /// When false (e.g. change passcode → SMS step), hides the 4-step registration indicator.
  final bool showRegistrationProgress;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final PinInputController _pinController = PinInputController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VerificationProvider>();
      provider.requestOtp();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VerificationProvider>();
    final l10n = context.l10n!;
    final theme = context.theme;
    final isDark = context.isDarkMode;

    final subtitleColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final indicatorInactiveColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.16 : 0.20,
    );
    final pinBorderColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const CommonBackButton(),
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              if (widget.showRegistrationProgress) ...[
                Row(
                  children: [
                    ...List.generate(4, (index) {
                      final isActive = index < 2;
                      return Padding(
                        padding: EdgeInsetsDirectional.only(
                          end: index < 3 ? 4 : 0,
                        ),
                        child: Container(
                          width: isActive ? 44 : 14,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primaryColor
                                : indicatorInactiveColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 28),
              ],
              Text(
                l10n.verifyYourAccount,
                style: GoogleFonts.poppinsTextTheme().displaySmall?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 1.24,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.verificationCodeSentViaSmsTo(
                  provider.formattedPhoneForDisplay,
                ),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: subtitleColor,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  const preferredCellSize = 56.0;
                  const preferredSpacing = 8.0;
                  const cellCount = VerificationProvider.otpLength;
                  final availableWidth = constraints.maxWidth;
                  final totalPreferredWidth =
                      cellCount * preferredCellSize +
                      (cellCount - 1) * preferredSpacing;
                  final cellWidth = totalPreferredWidth <= availableWidth
                      ? preferredCellSize
                      : (availableWidth - (cellCount - 1) * preferredSpacing) /
                            cellCount;
                  final cellSize = Size(
                    cellWidth.clamp(40.0, preferredCellSize),
                    preferredCellSize,
                  );

                  return MaterialPinField(
                    length: cellCount,
                    pinController: _pinController,
                    autoFocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    theme: MaterialPinTheme(
                      shape: MaterialPinShape.outlined,
                      cellSize: cellSize,
                      spacing: preferredSpacing,
                      borderRadius: BorderRadius.circular(16),
                      borderWidth: 1,
                      focusedBorderWidth: 1,
                      borderColor: pinBorderColor,
                      focusedBorderColor: pinBorderColor,
                      filledBorderColor: pinBorderColor,
                      textStyle: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                      cursorColor: theme.colorScheme.onSurface,
                    ),
                    onChanged: (value) => provider.setOtpFromString(value),
                    onCompleted: (pin) => _verifyOtp(provider),
                  );
                },
              ),
              const SizedBox(height: 16),
              _VerificationStatusText(provider: provider),
              const Spacer(),
            ],
          ),
        ),
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

class _VerificationStatusText extends StatelessWidget {
  const _VerificationStatusText({required this.provider});

  final VerificationProvider provider;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final mutedColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    if (provider.countdownSeconds > 0) {
      final full = l10n.verificationCodesInSeconds(provider.countdownSeconds);
      final secondsStr = provider.countdownSeconds.toString();
      final secondsPart = '$secondsStr Seconds';
      final prefix = full.replaceAll(secondsPart, '').trim();
      return RichText(
        textAlign: TextAlign.start,
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: mutedColor,
          ),
          children: [
            if (prefix.isNotEmpty) TextSpan(text: '$prefix '),
            TextSpan(
              text: secondsPart,
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final prefix = l10n.didntReceiveCodesResendOtp
        .replaceAll(l10n.resendOtp, '')
        .trim();
    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: mutedColor,
        ),
        children: [
          if (prefix.isNotEmpty) TextSpan(text: '$prefix '),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: provider.canResend ? () => provider.resendOtp() : null,
              child: Text(
                l10n.resendOtp,
                style: TextStyle(
                  color: provider.canResend
                      ? AppColors.primaryColor
                      : mutedColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
