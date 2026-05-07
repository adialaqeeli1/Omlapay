import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common_back_button.dart';
import '../../../widgets/common_loading_indicator.dart';
import '../../../widgets/logout_alert_dialog.dart';
import '../providers/login_provider.dart';
import '../providers/passcode_provider.dart';
import '../services/forgot_passcode_service.dart';
import '../../settings/services/change_email_service.dart';
import '../../settings/services/change_phone_service.dart';

class EnterOrSetPasscodeScreen extends StatefulWidget {
  /// Prevents overlapping forgot-passcode OTP requests before the loading overlay
  /// blocks further taps.
  static bool _forgotPasscodeOtpInFlight = false;

  /// Settings → change passcode: avoids double-submit while change-passcode API runs.
  static bool _changePasscodeSubmitInFlight = false;

  const EnterOrSetPasscodeScreen({
    super.key,
    this.isSoftLogin = false,
    this.mode,
    this.currentPasscode,
    this.pendingPasscode,
    this.resetToken,
    this.pendingEmail,
    this.changeEmailToken,
    this.changePhoneToken,
    this.registrationToken,
  });

  final bool isSoftLogin;
  final String? mode;
  final String? currentPasscode;
  final String? pendingPasscode;
  final String? resetToken;
  final String? pendingEmail;
  final String? changeEmailToken;
  final String? changePhoneToken;
  final String? registrationToken;

  @override
  State<EnterOrSetPasscodeScreen> createState() =>
      _EnterOrSetPasscodeScreenState();
}

class _EnterOrSetPasscodeScreenState extends State<EnterOrSetPasscodeScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  PasscodeProvider? _passcodeProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<PasscodeProvider>();
    if (!identical(_passcodeProvider, provider)) {
      _passcodeProvider?.removeListener(_syncControllerFromProvider);
      _passcodeProvider = provider;
      _passcodeProvider!.addListener(_syncControllerFromProvider);
    }
  }

  @override
  void dispose() {
    _passcodeProvider?.removeListener(_syncControllerFromProvider);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Mirrors external clears / rejected digits onto the hidden capture field
  /// so the controller never drifts away from the provider state.
  void _syncControllerFromProvider() {
    final providerPasscode = _passcodeProvider?.passcode ?? '';
    if (_controller.text != providerPasscode) {
      _controller.value = TextEditingValue(
        text: providerPasscode,
        selection: TextSelection.collapsed(offset: providerPasscode.length),
      );
    }
  }

  void _ensureKeyboardOpen() {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
      return;
    }
    // Focus can be retained while the soft keyboard is hidden (system back
    // button, swipe-down, or a screen-lock cycle). In that state
    // requestFocus() is a no-op, so ask the platform to re-show it.
    SystemChannels.textInput.invokeMethod<void>('TextInput.show');
  }

  Future<void> _onHiddenInputChanged(
    String value,
    PasscodeProvider provider,
  ) async {
    final prev = provider.passcode;
    if (value.length > prev.length) {
      final added = value.substring(prev.length);
      for (final ch in added.split('')) {
        if (!provider.canEnterDigits) break;
        await _onDigitPressed(context, provider, ch);
      }
    } else if (value.length < prev.length) {
      final removeCount = prev.length - value.length;
      for (var i = 0; i < removeCount; i++) {
        provider.removeLastDigit();
      }
    }
    // Force the controller back in sync so any digits the provider rejected
    // (length cap, verifying gate) don't leave the field ahead of state.
    final synced = provider.passcode;
    if (_controller.text != synced) {
      _controller.value = TextEditingValue(
        text: synced,
        selection: TextSelection.collapsed(offset: synced.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final passcodeProvider = context.watch<PasscodeProvider>();
    final l10n = context.l10n!;
    final theme = context.theme;
    final isDark = context.isDarkMode;

    final subtitleColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.90 : 0.62,
    );
    final emptyDotBorderColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.92 : 0.32,
    );
    final activeDotColor = AppColors.primaryColor;
    final errorColor = theme.colorScheme.error;
    final indicatorInactiveColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.16 : 0.20,
    );
    final isRegisterMode = widget.mode == LoginProvider.modeRegister;
    final isChangePasscodeFlow =
        widget.mode == LoginProvider.modeChangePasscodeCurrent ||
        widget.mode == LoginProvider.modeChangePasscodeNew ||
        widget.mode == LoginProvider.modeChangePasscodeConfirm;
    final isChangeEmailPasscodeStep =
        widget.mode == LoginProvider.modeChangeEmailConfirmPasscode;
    final isChangePhonePasscodeStep =
        widget.mode == LoginProvider.modeChangePhoneConfirmPasscode;
    final isAccountPasscodeStep =
        isChangeEmailPasscodeStep || isChangePhonePasscodeStep;

    return Scaffold(
      appBar: AppBar(
        leading: context.canPop() == false
            ? null
            : widget.isSoftLogin
            ? null
            : (isRegisterMode
                  ? CommonBackButton()
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
        actions: widget.isSoftLogin
            ? [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 16),
                  child: InkWell(
                    onTap: () => _showLogoutAlert(context),
                    child: Container(
                      // width: 71,
                      height: kMinInteractiveDimension - 5,
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
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: context.isDarkMode
              ? Brightness.light
              : Brightness.dark,
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _ensureKeyboardOpen,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20).copyWith(
                    top: widget.isSoftLogin ? 20 : (isRegisterMode ? 28 : 0),
                  ),
                  child: Column(
                    children: [
                      const Spacer(),
                      if (!isRegisterMode &&
                          !isChangePasscodeFlow &&
                          !isAccountPasscodeStep)
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
                          !isAccountPasscodeStep)
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
                        textDirection: TextDirection.ltr,
                        children: [
                          for (
                            var index = 0;
                            index < PasscodeProvider.passcodeLength;
                            index++
                          ) ...[
                            _PasscodeDot(
                              isFilled:
                                  index < passcodeProvider.enteredDigitsCount,
                              fillColor: passcodeProvider.hasError
                                  ? errorColor
                                  : activeDotColor,
                              borderColor:
                                  index < passcodeProvider.enteredDigitsCount
                                  ? (passcodeProvider.hasError
                                        ? errorColor
                                        : activeDotColor)
                                  : emptyDotBorderColor,
                            ),
                            if (index < PasscodeProvider.passcodeLength - 1)
                              const SizedBox(width: 12),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 22,
                        child: passcodeProvider.hasError
                            ? Text(
                                widget.mode ==
                                            LoginProvider.modeConfirmPasscode ||
                                        widget.mode ==
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
                          onTap: () =>
                              _onForgotPasscode(context, passcodeProvider),
                          child: Text(
                            l10n.forgotPasscode,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const Spacer(),
                      // Hidden capture field: drives the device numpad while
                      // staying invisible. The dots row above is the visible
                      // indicator; tapping anywhere in the body re-opens the
                      // keyboard via [_ensureKeyboardOpen].
                      SizedBox(
                        width: 0,
                        height: 0,
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          autofocus: true,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: false,
                            signed: false,
                          ),
                          textInputAction: TextInputAction.done,
                          showCursor: false,
                          obscureText: true,
                          autocorrect: false,
                          enableSuggestions: false,
                          enableInteractiveSelection: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(
                              PasscodeProvider.passcodeLength,
                            ),
                          ],
                          onChanged: (value) =>
                              _onHiddenInputChanged(value, passcodeProvider),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  /// Leading control for the change-passcode flow. Step transitions use
  /// [context.pushReplacement] so the `[home, settings]` stack prefix is
  /// preserved, letting the default pop-based back button work all the way out.
  Widget? _changePasscodeBackButton(BuildContext context) {
    // if (mode == LoginProvider.modeChangePasscodeNew) {
    //   return CommonBackButton(
    //     onPressed: () {
    //       final provider = context.read<PasscodeProvider>();
    //       context.push(
    //         Routes.enterOrSetPasscode,
    //         extra: {
    //           LoginProvider.extraModeKey:
    //               LoginProvider.modeChangePasscodeCurrent,
    //           LoginProvider.extraCountryCodeKey: provider.countryCode,
    //           LoginProvider.extraPhoneNumberKey: provider.phoneNumber,
    //         },
    //       );
    //     },
    //   );
    // }
    // if (mode == LoginProvider.modeChangePasscodeConfirm) {
    //   return CommonBackButton(
    //     onPressed: () {
    //       final provider = context.read<PasscodeProvider>();
    //       context.pushReplacement(
    //         Routes.enterOrSetPasscode,
    //         extra: {
    //           LoginProvider.extraModeKey: LoginProvider.modeChangePasscodeNew,
    //           LoginProvider.extraCountryCodeKey: provider.countryCode,
    //           LoginProvider.extraPhoneNumberKey: provider.phoneNumber,
    //           LoginProvider.extraCurrentPasscodeKey: currentPasscode,
    //         },
    //       );
    //     },
    //   );
    // }
    return CommonBackButton();
  }

  /// Back navigation for change-email passcode confirmation (step 3).
  /// The screen is reached via [context.push] from the verify-phone step,
  /// so the default pop is correct here.
  Widget? _changeEmailPasscodeBackButton(BuildContext context) {
    if (widget.mode != LoginProvider.modeChangeEmailConfirmPasscode) {
      return null;
    }
    return context.canPop() ? const CommonBackButton() : null;
  }

  bool _showForgotPasscodeLink() {
    if (widget.mode == LoginProvider.modeResetPasscode ||
        widget.mode == LoginProvider.modeConfirmPasscode ||
        widget.mode == LoginProvider.modeRegister ||
        widget.mode == LoginProvider.modeChangePasscodeCurrent ||
        widget.mode == LoginProvider.modeChangePasscodeNew ||
        widget.mode == LoginProvider.modeChangePasscodeConfirm ||
        widget.mode == LoginProvider.modeChangeEmailConfirmPasscode ||
        widget.mode == LoginProvider.modeChangePhoneConfirmPasscode) {
      return false;
    }
    return true;
  }

  String _titleForMode(dynamic l10n) {
    return switch (widget.mode) {
      LoginProvider.modeRegister => l10n.createAPasscode,
      LoginProvider.modeChangePasscodeCurrent => l10n.enterYourCurrentPasscode,
      LoginProvider.modeChangePasscodeNew => l10n.enterYourNewPasscode,
      LoginProvider.modeChangePasscodeConfirm => l10n.confirmYourNewPasscode,
      LoginProvider.modeChangeEmailConfirmPasscode => l10n.enterPasscode,
      LoginProvider.modeChangePhoneConfirmPasscode => l10n.enterPasscode,
      LoginProvider.modeResetPasscode => l10n.setYourNewPasscode,
      LoginProvider.modeConfirmPasscode => l10n.confirmYourPasscode,
      _ => l10n.enterPasscode,
    };
  }

  static Future<void> _onForgotPasscode(
    BuildContext context,
    PasscodeProvider passcodeProvider,
  ) async {
    if (!passcodeProvider.hasPhoneContext) {
      if (context.mounted) {
        SnackbarHelper.showError(
          context,
          context.l10n!.forgotPasscodePhoneMissing,
        );
      }
      return;
    }
    if (EnterOrSetPasscodeScreen._forgotPasscodeOtpInFlight) {
      return;
    }
    EnterOrSetPasscodeScreen._forgotPasscodeOtpInFlight = true;
    try {
      passcodeProvider.clearPasscode();

      final navigator = Navigator.of(context, rootNavigator: true);
      final barrierColor = Theme.of(
        context,
      ).colorScheme.scrim.withValues(alpha: 0.45);

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: barrierColor,
        useRootNavigator: true,
        builder: (dialogContext) {
          return PopScope(
            canPop: false,
            child: Center(
              child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox.square(
                  dimension: 60,
                  child: const CommonLoadingIndicator(),
                ),
              ),
            ),
          );
        },
      );
      // Let the dialog route mount before the async API gap so [Navigator.pop]
      // reliably dismisses the loading overlay.
      await Future<void>.delayed(Duration.zero);
      if (!context.mounted) {
        if (navigator.mounted) {
          navigator.pop();
        }
        return;
      }

      try {
        final response = await ForgotPasscodeService.requestOtp(
          passcodeProvider.phoneNumber,
          passcodeProvider.countryCode,
        );
        if (navigator.mounted) {
          navigator.pop();
        }
        if (context.mounted) {
          context.push(
            Routes.forgotPasscode,
            extra: {
              LoginProvider.extraCountryCodeKey: passcodeProvider.countryCode,
              LoginProvider.extraPhoneNumberKey: passcodeProvider.phoneNumber,
              'otpExpirySeconds': response.otpExpirySeconds,
              'maskedMobile': response.maskedMobile,
              'maskedEmail': response.maskedEmail,
              'verificationType': response.verificationType,
            },
          );
        }
      } catch (e) {
        if (navigator.mounted) {
          navigator.pop();
        }
        if (context.mounted) {
          SnackbarHelper.showError(context, e.toString());
        }
      }
    } finally {
      EnterOrSetPasscodeScreen._forgotPasscodeOtpInFlight = false;
    }
  }

  Future<void> _onDigitPressed(
    BuildContext context,
    PasscodeProvider provider,
    String digit,
  ) async {
    print(widget.mode);
    provider.addDigit(digit);
    if (!provider.isComplete) {
      return;
    }

    try {
      if (widget.mode == LoginProvider.modeResetPasscode) {
        if (widget.resetToken == null || widget.resetToken!.isEmpty) {
          SnackbarHelper.showError(context, context.l10n!.unknownError);
          return;
        }
        context.push(
          Routes.enterOrSetPasscode,
          extra: {
            LoginProvider.extraModeKey: LoginProvider.modeConfirmPasscode,
            LoginProvider.extraCountryCodeKey: provider.countryCode,
            LoginProvider.extraPhoneNumberKey: provider.phoneNumber,
            LoginProvider.extraPendingPasscodeKey: provider.passcode,
            LoginProvider.extraResetTokenKey: widget.resetToken,
          },
        );
        return;
      }

      final authProvider = context.read<AuthProvider>();

      if (widget.mode == LoginProvider.modeChangePasscodeCurrent) {
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
        context.push(
          Routes.enterOrSetPasscode,
          extra: {
            LoginProvider.extraModeKey: LoginProvider.modeChangePasscodeNew,
            LoginProvider.extraCountryCodeKey: provider.countryCode,
            LoginProvider.extraPhoneNumberKey: provider.phoneNumber,
            LoginProvider.extraCurrentPasscodeKey: provider.passcode,
          },
        );
        return;
      }

      if (widget.mode == LoginProvider.modeChangePasscodeNew) {
        context.push(
          Routes.enterOrSetPasscode,
          extra: {
            LoginProvider.extraModeKey: LoginProvider.modeChangePasscodeConfirm,
            LoginProvider.extraCountryCodeKey: provider.countryCode,
            LoginProvider.extraPhoneNumberKey: provider.phoneNumber,
            LoginProvider.extraCurrentPasscodeKey: widget.currentPasscode,
            LoginProvider.extraPendingPasscodeKey: provider.passcode,
          },
        );
        return;
      }

      if (widget.mode == LoginProvider.modeRegister) {
        final isValid = await provider.verify(
          verifyPasscode:
              ({
                required String phoneNumber,
                required String countryCode,
                required String passcode,
              }) async {
                if (widget.registrationToken != null &&
                    widget.registrationToken!.isNotEmpty) {
                  final isRegSuccess = await authProvider
                      .setRegistrationPasscode(
                        registrationToken: widget.registrationToken!,
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

      if (widget.mode == LoginProvider.modeChangePasscodeConfirm) {
        final isValid = await provider.verify(
          verifyPasscode:
              ({
                required String phoneNumber,
                required String countryCode,
                required String passcode,
              }) async => passcode == (widget.pendingPasscode ?? ''),
        );
        if (!context.mounted || !isValid) {
          return;
        }
        final newPasscode = widget.pendingPasscode;
        final oldPasscode = widget.currentPasscode;
        if (newPasscode == null ||
            newPasscode.length != PasscodeProvider.passcodeLength ||
            oldPasscode == null ||
            oldPasscode.length != PasscodeProvider.passcodeLength) {
          if (context.mounted) {
            SnackbarHelper.showError(context, context.l10n!.unknownError);
          }
          return;
        }

        if (EnterOrSetPasscodeScreen._changePasscodeSubmitInFlight) {
          return;
        }
        EnterOrSetPasscodeScreen._changePasscodeSubmitInFlight = true;
        provider.clearPasscode();

        final navigator = Navigator.of(context, rootNavigator: true);
        final barrierColor = Theme.of(
          context,
        ).colorScheme.scrim.withValues(alpha: 0.45);

        showDialog<void>(
          context: context,
          barrierDismissible: false,
          barrierColor: barrierColor,
          useRootNavigator: true,
          builder: (dialogContext) {
            return PopScope(
              canPop: false,
              child: Center(
                child: Material(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SizedBox.square(
                    dimension: 60,
                    child: const CommonLoadingIndicator(),
                  ),
                ),
              ),
            );
          },
        );
        await Future<void>.delayed(Duration.zero);
        if (!context.mounted) {
          EnterOrSetPasscodeScreen._changePasscodeSubmitInFlight = false;
          if (navigator.mounted) {
            navigator.pop();
          }
          return;
        }

        try {
          await authProvider.changePasscodeAndRefreshSession(
            currentPasscode: oldPasscode,
            newPasscode: newPasscode,
            confirmPasscode: newPasscode,
            countryCode: provider.countryCode,
            mobileNumber: provider.phoneNumber,
          );
          if (navigator.mounted) {
            navigator.pop();
          }
          if (!context.mounted) {
            return;
          }
          context.go(Routes.changePasscodeSuccess);
        } catch (e) {
          if (navigator.mounted) {
            navigator.pop();
          }
          if (context.mounted) {
            SnackbarHelper.showError(context, e.toString());
          }
        } finally {
          EnterOrSetPasscodeScreen._changePasscodeSubmitInFlight = false;
        }
        return;
      }

      if (widget.mode == LoginProvider.modeConfirmPasscode) {
        final isForgotResetFlow =
            widget.resetToken != null && widget.resetToken!.isNotEmpty;
        final isValid = await provider.verify(
          verifyPasscode:
              ({
                required String phoneNumber,
                required String countryCode,
                required String passcode,
              }) async {
                if (passcode != (widget.pendingPasscode ?? '')) return false;
                if (isForgotResetFlow) {
                  return await authProvider.resetForgotPasscodeAndLogin(
                    phoneNumber: phoneNumber,
                    countryCode: countryCode,
                    resetToken: widget.resetToken!,
                    newPasscode: passcode,
                    confirmPasscode: passcode,
                  );
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

      if (widget.mode == LoginProvider.modeChangeEmailConfirmPasscode) {
        final token = widget.changeEmailToken?.trim() ?? '';
        if (token.isEmpty) {
          return;
        }
        String? refreshedToken;
        final isValid = await provider.verify(
          verifyPasscode:
              ({
                required String phoneNumber,
                required String countryCode,
                required String passcode,
              }) async {
                final result = await ChangeEmailService.step3VerifyPasscode(
                  changeEmailToken: token,
                  passcode: passcode,
                );
                refreshedToken = result.changeEmailToken;
                return true;
              },
        );
        if (!context.mounted || !isValid) return;
        final nextToken = (refreshedToken != null && refreshedToken!.isNotEmpty)
            ? refreshedToken!
            : token;
        context.push(
          Routes.changeEmailEnterNew,
          extra: {LoginProvider.extraChangeEmailTokenKey: nextToken},
        );
        return;
      }

      if (widget.mode == LoginProvider.modeChangePhoneConfirmPasscode) {
        final token = widget.changePhoneToken?.trim() ?? '';
        if (token.isEmpty) {
          return;
        }
        String? refreshedToken;
        final isValid = await provider.verify(
          verifyPasscode:
              ({
                required String phoneNumber,
                required String countryCode,
                required String passcode,
              }) async {
                final result = await ChangePhoneService.step3VerifyPasscode(
                  changePhoneToken: token,
                  passcode: passcode,
                );
                refreshedToken = result.changePhoneToken;
                return true;
              },
        );
        if (!context.mounted || !isValid) return;
        final nextToken = (refreshedToken != null && refreshedToken!.isNotEmpty)
            ? refreshedToken!
            : token;
        context.push(
          Routes.changePhoneEnterNew,
          extra: {LoginProvider.extraChangePhoneTokenKey: nextToken},
        );
        return;
      }

      if (widget.mode == LoginProvider.modeSoftLogin) {
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
