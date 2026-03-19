import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common_back_button.dart';
import '../../../widgets/logout_alert_dialog.dart';
import '../providers/passcode_provider.dart';

class EnterOrSetPasscodeScreen extends StatelessWidget {
  const EnterOrSetPasscodeScreen({super.key, this.isSoftLogin = false});

  final bool isSoftLogin;

  @override
  Widget build(BuildContext context) {
    final passcodeProvider = context.watch<PasscodeProvider>();
    final l10n = context.l10n!;
    final theme = context.theme;
    final isDark = context.isDarkMode;

    final subtitleColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.90 : 0.62,
    );
    final keypadButtonColor = isDark
        ? AppColors.iconBackground
        : theme.colorScheme.onSurface.withValues(alpha: 0.14);
    final keypadTextColor = isDark ? AppColors.white : AppColors.textBlack;
    final emptyDotBorderColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.92 : 0.32,
    );
    final activeDotColor = AppColors.primaryColor;
    final errorColor = theme.colorScheme.error;

    return Scaffold(
      appBar: AppBar(
        leading: isSoftLogin
            ? null
            : (context.canPop() ? CommonBackButton() : null),
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: isSoftLogin
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: InkWell(
                    onTap: () => _showLogoutAlert(context),
                    child: Container(
                      width: 71,
                      height: 37,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.logoutButtonBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        l10n.logout,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.3,
                          letterSpacing: 0,
                          color: AppColors.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                ).copyWith(top: isSoftLogin ? 20 : 0),
                child: Column(
                  children: [
                    Text(
                      l10n.welcomeToOmlaPay,
                      style: GoogleFonts.poppinsTextTheme().titleMedium
                          ?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: subtitleColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.enterPasscode,
                      style: GoogleFonts.poppinsTextTheme().displaySmall
                          ?.copyWith(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            height: 1.24,
                            color: theme.colorScheme.onSurface,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(PasscodeProvider.passcodeLength, (
                        index,
                      ) {
                        final isFilled =
                            index < passcodeProvider.enteredDigitsCount;
                        final dotColor = passcodeProvider.hasError
                            ? errorColor
                            : activeDotColor;
                        return Padding(
                          padding: EdgeInsetsDirectional.only(
                            end: index == PasscodeProvider.passcodeLength - 1
                                ? 0
                                : 12,
                          ),
                          child: _PasscodeDot(
                            isFilled: isFilled,
                            fillColor: dotColor,
                            borderColor: isFilled
                                ? dotColor
                                : emptyDotBorderColor,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 22,
                      child: passcodeProvider.hasError
                          ? Text(
                              l10n.incorrectPasscodeTryAgain,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: errorColor,
                              ),
                              textAlign: TextAlign.center,
                            )
                          : null,
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _onForgotPasscode(
                        context,
                        isSoftLogin,
                        passcodeProvider,
                      ),
                      child: Text(
                        l10n.forgotPasscode,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 18 / 1.35,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Spacer(),
                    _KeypadGrid(
                      onDigitPressed: (digit) =>
                          _onDigitPressed(context, passcodeProvider, digit),
                      onBackspacePressed: passcodeProvider.removeLastDigit,
                      buttonColor: keypadButtonColor,
                      buttonTextColor: keypadTextColor,
                      isEnabled: passcodeProvider.canEnterDigits,
                    ),
                    const Spacer(),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showLogoutAlert(BuildContext context) {
    LogoutAlertDialog.show(context, onLogout: () => _onLogout(context));
  }

  static Future<void> _onLogout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (context.mounted) {
      context.go(Routes.login);
    }
  }

  static void _onForgotPasscode(
    BuildContext context,
    bool isSoftLogin,
    PasscodeProvider passcodeProvider,
  ) {
    passcodeProvider.clearPasscode();
    if (isSoftLogin) {
      _onLogout(context);
    } else {
      context.pop();
    }
  }

  Future<void> _onDigitPressed(
    BuildContext context,
    PasscodeProvider provider,
    String digit,
  ) async {
    provider.addDigit(digit);
    if (!provider.isComplete) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final isValid = await provider.verify(
      verifyPasscode:
          ({
            required String phoneNumber,
            required String countryCode,
            required String passcode,
          }) => authProvider.login(phoneNumber, countryCode, passcode),
    );
    if (!context.mounted || !isValid) {
      return;
    }
    context.go(Routes.home);
  }
}

class _PasscodeDot extends StatelessWidget {
  const _PasscodeDot({
    required this.isFilled,
    required this.fillColor,
    required this.borderColor,
  });

  final bool isFilled;
  final Color fillColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? fillColor : Colors.transparent,
        border: Border.all(color: borderColor, width: 1.2),
      ),
    );
  }
}

class _KeypadGrid extends StatelessWidget {
  const _KeypadGrid({
    required this.onDigitPressed,
    required this.onBackspacePressed,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.isEnabled,
  });

  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspacePressed;
  final Color buttonColor;
  final Color buttonTextColor;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    const keypadRows = <List<String>>[
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];

    return Column(
      children: [
        for (final row in keypadRows)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < row.length; index++)
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: index == row.length - 1 ? 0 : 18,
                    ),
                    child: _KeypadButton(
                      label: row[index],
                      onPressed: isEnabled
                          ? () => onDigitPressed(row[index])
                          : null,
                      buttonColor: buttonColor,
                      textColor: buttonTextColor,
                    ),
                  ),
              ],
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 64, height: 64),
            const SizedBox(width: 18),
            _KeypadButton(
              label: '0',
              onPressed: isEnabled ? () => onDigitPressed('0') : null,
              buttonColor: buttonColor,
              textColor: buttonTextColor,
            ),
            const SizedBox(width: 18),
            SizedBox(
              width: 64,
              height: 64,
              child: Center(
                child: GestureDetector(
                  onTap: isEnabled ? onBackspacePressed : null,
                  child: SvgPicture.asset(
                    context.isDarkMode
                        ? 'assets/icons/clear-number-icon-dark.svg'
                        : 'assets/icons/clear-number-icon-light.svg',
                    width: 28,
                    height: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.label,
    required this.onPressed,
    required this.buttonColor,
    required this.textColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color buttonColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Opacity(
        opacity: onPressed == null ? 0.5 : 1,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(shape: BoxShape.circle, color: buttonColor),
          alignment: Alignment.center,
          child: Text(
            label,
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: 44 / 1.35,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
