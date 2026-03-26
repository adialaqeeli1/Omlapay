import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common_back_button.dart';
import '../../../widgets/logout_alert_dialog.dart';
import '../providers/login_provider.dart';
import '../providers/passcode_provider.dart';
import '../services/forgot_passcode_service.dart';

class EnterOrSetPasscodeScreen extends StatelessWidget {
  const EnterOrSetPasscodeScreen({
    super.key,
    this.isSoftLogin = false,
    this.mode,
    this.pendingPasscode,
    this.pendingEmail,
    this.registrationToken,
  });

  final bool isSoftLogin;
  final String? mode;
  final String? pendingPasscode;
  final String? pendingEmail;
  final String? registrationToken;

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
    final indicatorInactiveColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.16 : 0.20,
    );
    final isRegisterMode = mode == LoginProvider.modeRegister;
    final isChangePasscodeFlow =
        mode == LoginProvider.modeChangePasscodeCurrent ||
        mode == LoginProvider.modeChangePasscodeNew ||
        mode == LoginProvider.modeChangePasscodeConfirm;
    final isChangeEmailPasscodeStep =
        mode == LoginProvider.modeChangeEmailConfirmPasscode;

    return Scaffold(
      appBar: AppBar(
        leading: isSoftLogin
            ? null
            : (isRegisterMode
                  ? IconButton(
                      onPressed: () {
                        final provider = context.read<PasscodeProvider>();
                        context.go(
                          Routes.registerVerification,
                          extra: {
                            LoginProvider.extraCountryCodeKey:
                                provider.countryCode,
                            LoginProvider.extraPhoneNumberKey:
                                provider.phoneNumber,
                          },
                        );
                      },
                      icon: SvgPicture.asset(
                        context.textDirection == TextDirection.rtl
                            ? 'assets/icons/arrow_forward.svg'
                            : 'assets/icons/arrow_back.svg',
                        colorFilter: ColorFilter.mode(
                          context.isDarkMode
                              ? AppColors.white
                              : AppColors.darkSurface,
                          BlendMode.srcIn,
                        ),
                      ),
                    )
                  : _changePasscodeBackButton(context) ??
                        _changeEmailPasscodeBackButton(context) ??
                        (context.canPop() ? CommonBackButton() : null)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: isChangePasscodeFlow
            ? Text(
                l10n.changePasscode,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
        centerTitle: isChangePasscodeFlow,
        bottom: isRegisterMode
            ? PreferredSize(
                preferredSize: const Size.fromHeight(24),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(
                    children: [
                      ...List.generate(4, (index) {
                        final isActive = isRegisterMode
                            ? index == 3
                            : index <= 3;
                        final isCurrent = index == 3;
                        return Padding(
                          padding: EdgeInsetsDirectional.only(
                            end: index < 3 ? 4 : 0,
                          ),
                          child: Container(
                            width: isCurrent ? 44 : 14,
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
                ),
              )
            : null,
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
                ).copyWith(top: isSoftLogin ? 20 : (isRegisterMode ? 28 : 0)),
                child: Column(
                  children: [
                    if (isChangePasscodeFlow) const Spacer(),
                    if (!isRegisterMode &&
                        !isChangePasscodeFlow &&
                        !isChangeEmailPasscodeStep)
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
                    if (!isRegisterMode &&
                        !isChangePasscodeFlow &&
                        !isChangeEmailPasscodeStep)
                      const SizedBox(height: 24),
                    Text(
                      _titleForMode(l10n),
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
                              mode == LoginProvider.modeConfirmPasscode ||
                                      mode ==
                                          LoginProvider
                                              .modeChangePasscodeConfirm
                                  ? l10n.passcodesMismatchTryAgain
                                  : l10n.incorrectPasscodeTryAgain,
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
                    if (_showForgotPasscodeLink())
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
      context.go(Routes.loginOrRegister);
    }
  }

  /// Leading control for the whole change-passcode flow. Step transitions use
  /// [context.go], which can drop the [Routes.settings] stack entry, so the first
  /// step must not rely on [context.canPop] alone.
  Widget? _changePasscodeBackButton(BuildContext context) {
    if (mode == LoginProvider.modeChangePasscodeCurrent) {
      return CommonBackButton(
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(Routes.settings);
          }
        },
      );
    }
    if (mode == LoginProvider.modeChangePasscodeNew) {
      return CommonBackButton(
        onPressed: () {
          final provider = context.read<PasscodeProvider>();
          context.go(
            Routes.enterOrSetPasscode,
            extra: {
              LoginProvider.extraModeKey:
                  LoginProvider.modeChangePasscodeCurrent,
              LoginProvider.extraCountryCodeKey: provider.countryCode,
              LoginProvider.extraPhoneNumberKey: provider.phoneNumber,
            },
          );
        },
      );
    }
    if (mode == LoginProvider.modeChangePasscodeConfirm) {
      return CommonBackButton(
        onPressed: () {
          final provider = context.read<PasscodeProvider>();
          context.go(
            Routes.enterOrSetPasscode,
            extra: {
              LoginProvider.extraModeKey: LoginProvider.modeChangePasscodeNew,
              LoginProvider.extraCountryCodeKey: provider.countryCode,
              LoginProvider.extraPhoneNumberKey: provider.phoneNumber,
            },
          );
        },
      );
    }
    return null;
  }

  /// Back navigation for change-email passcode confirmation.
  /// The step is entered with [context.go], so we restore the previous route.
  Widget? _changeEmailPasscodeBackButton(BuildContext context) {
    if (mode != LoginProvider.modeChangeEmailConfirmPasscode) {
      return null;
    }

    return CommonBackButton(
      onPressed: () {
        final email = pendingEmail?.trim() ?? '';
        context.go(
          Routes.changeEmailVerifyNewEmail,
          extra: {LoginProvider.extraPendingEmailKey: email},
        );
      },
    );
  }

  bool _showForgotPasscodeLink() {
    if (mode == LoginProvider.modeResetPasscode ||
        mode == LoginProvider.modeConfirmPasscode ||
        mode == LoginProvider.modeRegister ||
        mode == LoginProvider.modeChangePasscodeCurrent ||
        mode == LoginProvider.modeChangePasscodeNew ||
        mode == LoginProvider.modeChangePasscodeConfirm ||
        mode == LoginProvider.modeChangeEmailConfirmPasscode) {
      return false;
    }
    return true;
  }

  String _titleForMode(dynamic l10n) {
    return switch (mode) {
      LoginProvider.modeRegister => l10n.createAPasscode,
      LoginProvider.modeChangePasscodeCurrent => l10n.enterYourCurrentPasscode,
      LoginProvider.modeChangePasscodeNew => l10n.enterYourNewPasscode,
      LoginProvider.modeChangePasscodeConfirm => l10n.confirmYourNewPasscode,
      LoginProvider.modeChangeEmailConfirmPasscode => l10n.enterPasscode,
      LoginProvider.modeResetPasscode => l10n.setYourNewPasscode,
      LoginProvider.modeConfirmPasscode => l10n.confirmYourPasscode,
      _ => l10n.enterPasscode,
    };
  }

  static Future<void> _onForgotPasscode(
    BuildContext context,
    bool isSoftLogin,
    PasscodeProvider passcodeProvider,
  ) async {
    if (!passcodeProvider.hasPhoneContext) return;
    passcodeProvider.clearPasscode();
    try {
      await ForgotPasscodeService.requestOtp(
        passcodeProvider.phoneNumber,
        passcodeProvider.countryCode,
      );
      if (context.mounted) {
        context.push(
          Routes.forgotPasscode,
          extra: {
            LoginProvider.extraCountryCodeKey: passcodeProvider.countryCode,
            LoginProvider.extraPhoneNumberKey: passcodeProvider.phoneNumber,
          },
        );
      }
    } catch (_) {
      if (context.mounted) {
        SnackbarHelper.showError(
          context,
          context.l10n!.networkError,
        );
      }
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

    try {
      if (mode == LoginProvider.modeResetPasscode) {
      context.go(
        Routes.enterOrSetPasscode,
        extra: {
          LoginProvider.extraModeKey: LoginProvider.modeConfirmPasscode,
          LoginProvider.extraCountryCodeKey: provider.countryCode,
          LoginProvider.extraPhoneNumberKey: provider.phoneNumber,
          LoginProvider.extraPendingPasscodeKey: provider.passcode,
        },
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();

    if (mode == LoginProvider.modeChangePasscodeCurrent) {
      final isValid = await provider.verify(
        verifyPasscode:
            ({
              required String phoneNumber,
              required String countryCode,
              required String passcode,
            }) => authProvider.verifyStoredPasscodeForCurrentUser(passcode),
      );
      if (!context.mounted || !isValid) {
        return;
      }
      context.go(
        Routes.enterOrSetPasscode,
        extra: {
          LoginProvider.extraModeKey: LoginProvider.modeChangePasscodeNew,
          LoginProvider.extraCountryCodeKey: provider.countryCode,
          LoginProvider.extraPhoneNumberKey: provider.phoneNumber,
        },
      );
      return;
    }

    if (mode == LoginProvider.modeChangePasscodeNew) {
      context.go(
        Routes.enterOrSetPasscode,
        extra: {
          LoginProvider.extraModeKey: LoginProvider.modeChangePasscodeConfirm,
          LoginProvider.extraCountryCodeKey: provider.countryCode,
          LoginProvider.extraPhoneNumberKey: provider.phoneNumber,
          LoginProvider.extraPendingPasscodeKey: provider.passcode,
        },
      );
      return;
    }

    if (mode == LoginProvider.modeRegister) {
      final isValid = await provider.verify(
        verifyPasscode:
            ({
              required String phoneNumber,
              required String countryCode,
              required String passcode,
            }) async {
              if (registrationToken != null && registrationToken!.isNotEmpty) {
                final isRegSuccess = await authProvider.setRegistrationPasscode(
                  registrationToken: registrationToken!,
                  passcode: passcode,
                  confirmPasscode: passcode,
                );
                if (isRegSuccess) {
                  return await authProvider.login(
                    phoneNumber,
                    countryCode,
                    passcode,
                  );
                }
                return false;
              }
              return await authProvider.setPasscode(
                phoneNumber,
                countryCode,
                passcode,
              );
            },
      );
      if (!context.mounted || !isValid) return;
      context.go(Routes.home);
      return;
    }

    if (mode == LoginProvider.modeChangePasscodeConfirm) {
      final isValid = await provider.verify(
        verifyPasscode:
            ({
              required String phoneNumber,
              required String countryCode,
              required String passcode,
            }) async => passcode == (pendingPasscode ?? ''),
      );
      if (!context.mounted || !isValid) {
        return;
      }
      final newPasscode = pendingPasscode;
      if (newPasscode == null || newPasscode.length != 6) {
        return;
      }
      context.go(
        Routes.registerVerification,
        extra: {
          LoginProvider.extraCountryCodeKey: provider.countryCode,
          LoginProvider.extraPhoneNumberKey: provider.phoneNumber,
          LoginProvider.extraPendingPasscodeKey: newPasscode,
          LoginProvider.extraVerificationPurposeKey:
              LoginProvider.purposeChangePasscode,
        },
      );
      return;
    }

    if (mode == LoginProvider.modeConfirmPasscode) {
      final isValid = await provider.verify(
        verifyPasscode:
            ({
              required String phoneNumber,
              required String countryCode,
              required String passcode,
            }) async {
              if (passcode != (pendingPasscode ?? '')) return false;
              return await authProvider.setPasscode(
                phoneNumber,
                countryCode,
                passcode,
              );
            },
      );
      if (!context.mounted || !isValid) return;
      context.go(Routes.home);
      return;
    }

    if (mode == LoginProvider.modeChangeEmailConfirmPasscode) {
      final email = pendingEmail?.trim() ?? '';
      if (email.isEmpty) {
        return;
      }
      final isValid = await provider.verify(
        verifyPasscode:
            ({
              required String phoneNumber,
              required String countryCode,
              required String passcode,
            }) => authProvider.verifyStoredPasscodeForCurrentUser(passcode),
      );
      if (!context.mounted || !isValid) return;
      final updated = await authProvider.updateEmailForCurrentUser(email);
      if (!context.mounted || !updated) return;
      context.go(Routes.changeEmailSuccess);
      return;
    }

    if (mode == LoginProvider.modeSoftLogin) {
      final isValid = await provider.verify(
        verifyPasscode:
            ({
              required String phoneNumber,
              required String countryCode,
              required String passcode,
            }) => authProvider.softLogin(passcode),
      );
      if (!context.mounted || !isValid) return;
      context.go(Routes.home);
      return;
    }

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
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(context, e.toString());
      }
    }
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
      textDirection: TextDirection.ltr,
      children: [
        for (final row in keypadRows)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              textDirection: TextDirection.ltr,
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
          textDirection: TextDirection.ltr,
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
