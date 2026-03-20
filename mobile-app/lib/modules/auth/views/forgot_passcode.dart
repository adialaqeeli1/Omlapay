import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../modules/auth/providers/login_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common_back_button.dart';
import '../providers/forgot_passcode_provider.dart';

class ForgotPasscodeScreen extends StatefulWidget {
  const ForgotPasscodeScreen({super.key});

  @override
  State<ForgotPasscodeScreen> createState() => _ForgotPasscodeScreenState();
}

class _ForgotPasscodeScreenState extends State<ForgotPasscodeScreen> {
  final PinInputController _pinController = PinInputController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ForgotPasscodeProvider>();
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
    final provider = context.watch<ForgotPasscodeProvider>();
    final l10n = context.l10n!;
    final theme = context.theme;
    final isDark = context.isDarkMode;

    final subtitleColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.6 : 0.6,
    );
    // Figma: border #FFFFFF, 1px; inactive state can use same or subtle
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      l10n.forgotPasscodeTitle,
                      style: GoogleFonts.poppinsTextTheme().displaySmall
                          ?.copyWith(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            height: 1.24,
                            color: theme.colorScheme.onSurface,
                          ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    'assets/icons/lock.svg',
                    width: 28,
                    height: 28,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.verifyYourPhoneNumber,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: subtitleColor,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 12),
              Text(
                provider.formattedPhoneForDisplay,
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
                  const cellCount = ForgotPasscodeProvider.otpLength;
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
              _StatusText(provider: provider),
              const Spacer(),
              Center(
                child: TextButton(
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
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOtp(ForgotPasscodeProvider provider) async {
    final isValid = await provider.verifyOtp();
    if (!mounted) return;
    if (isValid) {
      context.go(
        Routes.enterOrSetPasscode,
        extra: {
          LoginProvider.extraModeKey: LoginProvider.modeResetPasscode,
          LoginProvider.extraCountryCodeKey: provider.countryCode,
          LoginProvider.extraPhoneNumberKey: provider.phoneNumber,
        },
      );
    }
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({required this.provider});

  final ForgotPasscodeProvider provider;

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
