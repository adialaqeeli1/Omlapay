import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../widgets/common_back_button.dart';
import '../providers/change_email_otp_provider.dart';

class ChangeEmailVerifyOtpView extends StatefulWidget {
  const ChangeEmailVerifyOtpView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.stepIndex,
    required this.onVerified,
  });

  final String title;
  final String subtitle;
  final int stepIndex;
  final Future<void> Function(BuildContext context) onVerified;

  @override
  State<ChangeEmailVerifyOtpView> createState() =>
      _ChangeEmailVerifyOtpViewState();
}

class _ChangeEmailVerifyOtpViewState extends State<ChangeEmailVerifyOtpView> {
  final PinInputController _pinController = PinInputController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChangeEmailOtpProvider>().requestOtp();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChangeEmailOtpProvider>();
    final l10n = context.l10n!;
    final theme = context.theme;
    // final isDark = context.isDarkMode;
    // final indicatorInactiveColor = theme.colorScheme.onSurface.withValues(
    //   alpha: isDark ? 0.16 : 0.20,
    // );
    final pinBorderColor = theme.colorScheme.onSurface;
    final subtitleColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Scaffold(
      appBar: AppBar(
        leading: const CommonBackButton(),
        title: Text(
          l10n.changeEmail,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
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
              // Row(
              //   children: [
              //     ...List.generate(4, (index) {
              //       final isActive = index < widget.stepIndex;
              //       return Padding(
              //         padding: EdgeInsetsDirectional.only(
              //           end: index < 3 ? 4 : 0,
              //         ),
              //         child: Container(
              //           width: isActive ? 44 : 14,
              //           height: 6,
              //           decoration: BoxDecoration(
              //             color: isActive
              //                 ? AppColors.primaryColor
              //                 : indicatorInactiveColor,
              //             borderRadius: BorderRadius.circular(16),
              //           ),
              //         ),
              //       );
              //     }),
              //   ],
              // ),
              // const SizedBox(height: 28),
              Text(
                widget.title,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 1.24,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.subtitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  const preferredCellSize = 56.0;
                  const preferredSpacing = 8.0;
                  const cellCount = ChangeEmailOtpProvider.otpLength;
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
                    onChanged: provider.setOtp,
                    onCompleted: (_) => _verify(provider),
                  );
                },
              ),
              const SizedBox(height: 16),
              _StatusText(provider: provider),
              if (provider.hasError) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.invalidOtpTryAgain,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontSize: 14,
                  ),
                ),
              ],
              const Spacer(),
              Text(
                l10n.needHelpContactSupport,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verify(ChangeEmailOtpProvider provider) async {
    final valid = await provider.verifyOtp();
    if (!mounted || !valid) return;
    await widget.onVerified(context);
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({required this.provider});

  final ChangeEmailOtpProvider provider;

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
