import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';
import '../core/utils/app_exception.dart';
import '../core/utils/snackbar_helper.dart';
import 'common_back_button.dart';

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({
    super.key,
    required this.appBarTitle,
    required this.title,
    required this.subtitle,
    required this.otpLength,
    required this.countdownSeconds,
    required this.canResend,
    required this.hasError,
    required this.onInitialRequest,
    required this.onOtpChanged,
    required this.onOtpCompleted,
    required this.onResend,
    this.showProgress = false,
    this.totalProgressSteps = 4,
    this.activeProgressSteps = 2,
    this.titleStyle,
    this.bottomSection,
  });

  final String appBarTitle;
  final String title;
  final String subtitle;
  final int otpLength;
  final int countdownSeconds;
  final bool canResend;
  final bool hasError;
  final Future<void> Function() onInitialRequest;
  final void Function(String value) onOtpChanged;
  final Future<void> Function() onOtpCompleted;
  final Future<void> Function() onResend;
  final bool showProgress;
  final int totalProgressSteps;
  final int activeProgressSteps;
  final TextStyle? titleStyle;
  final Widget? bottomSection;

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final PinInputController _pinController = PinInputController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await widget.onInitialRequest();
      } catch (e) {
        if (!mounted) return;
        final message = e is AppException ? e.message : e.toString();
        SnackbarHelper.showError(context, message);
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final isDark = context.isDarkMode;
    final subtitleColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final pinBorderColor = theme.colorScheme.onSurface;
    final indicatorInactiveColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.16 : 0.20,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const CommonBackButton(),
        title: Text(
          widget.appBarTitle,
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
              if (widget.showProgress) ...[
                Row(
                  children: [
                    ...List.generate(widget.totalProgressSteps, (index) {
                      final isActive = index < widget.activeProgressSteps;
                      return Padding(
                        padding: EdgeInsetsDirectional.only(
                          end: index < widget.totalProgressSteps - 1 ? 4 : 0,
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
                widget.title,
                style:
                    widget.titleStyle ??
                    theme.textTheme.displaySmall?.copyWith(
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
                  final cellCount = widget.otpLength;
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
                    onChanged: widget.onOtpChanged,
                    onCompleted: (_) async => widget.onOtpCompleted(),
                  );
                },
              ),
              const SizedBox(height: 16),
              _OtpStatusText(
                countdownSeconds: widget.countdownSeconds,
                canResend: widget.canResend,
                onResend: widget.onResend,
              ),
              if (widget.hasError) ...[
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
              if (widget.bottomSection != null) ...[
                Center(child: widget.bottomSection!),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpStatusText extends StatelessWidget {
  const _OtpStatusText({
    required this.countdownSeconds,
    required this.canResend,
    required this.onResend,
  });

  final int countdownSeconds;
  final bool canResend;
  final Future<void> Function() onResend;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final mutedColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    if (countdownSeconds > 0) {
      return RichText(
        textAlign: TextAlign.start,
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: mutedColor,
          ),
          children: [
            TextSpan(text: '${l10n.verificationCodesIn} '),
            TextSpan(
              text: l10n.secondsCount(countdownSeconds),
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
              onTap: canResend ? () => onResend() : null,
              child: Text(
                l10n.resendOtp,
                style: TextStyle(
                  color: canResend ? AppColors.primaryColor : mutedColor,
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
