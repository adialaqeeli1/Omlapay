import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';
import '../core/utils/app_exception.dart';
import '../core/utils/snackbar_helper.dart';
import 'common_back_button.dart';

/// A verification view that shows both phone OTP and email OTP fields
/// when two-factor authentication is enabled.
///
/// Used in change-phone and change-email flows (step 2) when the user
/// has 2FA enabled — the API sends OTPs to both phone and email.
class TwoFactorOtpVerificationView extends StatefulWidget {
  const TwoFactorOtpVerificationView({
    super.key,
    required this.appBarTitle,
    required this.phoneTitle,
    required this.phoneSubtitle,
    required this.emailTitle,
    required this.emailSubtitle,
    required this.otpLength,
    required this.countdownSeconds,
    required this.canResend,
    required this.phoneHasError,
    required this.emailHasError,
    required this.onInitialRequest,
    required this.onPhoneOtpChanged,
    required this.onEmailOtpChanged,
    required this.onBothOtpCompleted,
    required this.onResend,
    this.bottomSection,
  });

  final String appBarTitle;
  final String phoneTitle;
  final String phoneSubtitle;
  final String emailTitle;
  final String emailSubtitle;
  final int otpLength;
  final int countdownSeconds;
  final bool canResend;
  final bool phoneHasError;
  final bool emailHasError;
  final Future<void> Function() onInitialRequest;
  final void Function(String value) onPhoneOtpChanged;
  final void Function(String value) onEmailOtpChanged;
  final Future<void> Function() onBothOtpCompleted;
  final Future<void> Function() onResend;
  final Widget? bottomSection;

  @override
  State<TwoFactorOtpVerificationView> createState() =>
      _TwoFactorOtpVerificationViewState();
}

class _TwoFactorOtpVerificationViewState
    extends State<TwoFactorOtpVerificationView> {
  final PinInputController _phonePinController = PinInputController();
  final PinInputController _emailPinController = PinInputController();
  bool _phoneCompleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await widget.onInitialRequest();
      } catch (e) {
        if (!mounted) return;
        final message = e is AppException
            ? e.localizedMessage(context.l10n)
            : e.toString();
        SnackbarHelper.showError(context, message);
      }
    });
  }

  @override
  void dispose() {
    _phonePinController.dispose();
    _emailPinController.dispose();
    super.dispose();
  }

  Future<void> _handleResend() async {
    _phonePinController.clear();
    _emailPinController.clear();
    widget.onPhoneOtpChanged('');
    widget.onEmailOtpChanged('');
    _phoneCompleted = false;
    await widget.onResend();
  }

  void _onPhoneOtpChanged(String value) {
    widget.onPhoneOtpChanged(value);
  }

  void _onPhoneOtpCompleted(String value) {
    _phoneCompleted = true;
    _emailPinController.requestFocus();
  }

  void _onEmailOtpCompleted(String value) {
    if (_phoneCompleted) {
      widget.onBothOtpCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

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
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Phone OTP section
                      _OtpSection(
                        title: widget.phoneTitle,
                        subtitle: widget.phoneSubtitle,
                        otpLength: widget.otpLength,
                        pinController: _phonePinController,
                        autoFocus: true,
                        hasError: widget.phoneHasError,
                        countdownSeconds: widget.countdownSeconds,
                        canResend: widget.canResend,
                        onResend: _handleResend,
                        onChanged: _onPhoneOtpChanged,
                        onCompleted: _onPhoneOtpCompleted,
                      ),
                      const SizedBox(height: 32),
                      // Email OTP section
                      _OtpSection(
                        title: widget.emailTitle,
                        subtitle: widget.emailSubtitle,
                        otpLength: widget.otpLength,
                        pinController: _emailPinController,
                        autoFocus: false,
                        hasError: widget.emailHasError,
                        countdownSeconds: widget.countdownSeconds,
                        canResend: widget.canResend,
                        onResend: _handleResend,
                        onChanged: widget.onEmailOtpChanged,
                        onCompleted: _onEmailOtpCompleted,
                      ),
                    ],
                  ),
                ),
              ),
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

/// A single OTP input section with title, subtitle, pin field, and countdown.
class _OtpSection extends StatelessWidget {
  const _OtpSection({
    required this.title,
    required this.subtitle,
    required this.otpLength,
    required this.pinController,
    required this.autoFocus,
    required this.hasError,
    required this.countdownSeconds,
    required this.canResend,
    required this.onResend,
    required this.onChanged,
    required this.onCompleted,
  });

  final String title;
  final String subtitle;
  final int otpLength;
  final PinInputController pinController;
  final bool autoFocus;
  final bool hasError;
  final int countdownSeconds;
  final bool canResend;
  final Future<void> Function() onResend;
  final void Function(String value) onChanged;
  final void Function(String value) onCompleted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final subtitleColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final pinBorderColor = theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            const preferredCellSize = 56.0;
            const preferredSpacing = 8.0;
            final cellCount = otpLength;
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
              pinController: pinController,
              autoFocus: autoFocus,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
              enabled: true,
              enablePaste: true,
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
              onChanged: onChanged,
              onCompleted: onCompleted,
            );
          },
        ),
        const SizedBox(height: 12),
        _OtpStatusText(
          countdownSeconds: countdownSeconds,
          canResend: canResend,
          onResend: onResend,
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          Text(
            l10n.invalidOtpTryAgain,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
              fontSize: 14,
            ),
          ),
        ],
      ],
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
