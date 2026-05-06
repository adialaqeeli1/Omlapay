import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../modules/auth/providers/login_provider.dart';
import '../../providers/auth_provider.dart';
import '../app_router.dart';

class AuthMiddleware {
  static String? isAuthenticated(BuildContext context, GoRouterState state) {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.state.isAuthenticated ||
        authProvider.state.user == null) {
      return Routes.loginOrRegister;
    }

    return null;
  }

  static String? isUnauthenticated(BuildContext context, GoRouterState state) {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.state.isAuthenticated) {
      return Routes.home;
    }

    return null;
  }

  /// Redirect for enterOrSetPasscode route. Behavior depends on route extra mode:
  /// - soft_login: require authenticated (else → login)
  /// - change_passcode_* : require authenticated (else → login)
  /// - reset_passcode, confirm_passcode: allow (forgot passcode flow)
  /// - hard_login, register, or unknown: require unauthenticated (else → home)
  static String? enterOrSetPasscode(BuildContext context, GoRouterState state) {
    final authProvider = context.read<AuthProvider>();
    final extra = state.extra;
    final mode = extra is Map<String, dynamic>
        ? extra[LoginProvider.extraModeKey] as String?
        : null;

    if (mode == LoginProvider.modeSoftLogin) {
      if (!authProvider.state.isAuthenticated ||
          authProvider.state.user == null) {
        return Routes.loginOrRegister;
      }
      return null;
    }

    if (mode == LoginProvider.modeResetPasscode ||
        mode == LoginProvider.modeConfirmPasscode) {
      return null;
    }

    if (mode == LoginProvider.modeChangePasscodeCurrent ||
        mode == LoginProvider.modeChangePasscodeNew ||
        mode == LoginProvider.modeChangePasscodeConfirm ||
        mode == LoginProvider.modeChangeEmailConfirmPasscode ||
        mode == LoginProvider.modeChangePhoneConfirmPasscode) {
      if (!authProvider.state.isAuthenticated ||
          authProvider.state.user == null) {
        return Routes.loginOrRegister;
      }
      return null;
    }

    if (authProvider.state.isAuthenticated) {
      return Routes.home;
    }
    return null;
  }

  /// Redirect for forgotPasscode route. Require valid extra (phone + country).
  static String? forgotPasscode(BuildContext context, GoRouterState state) {
    final extra = state.extra;
    if (extra is! Map<String, dynamic>) {
      return Routes.loginOrRegister;
    }
    final countryCode =
        extra[LoginProvider.extraCountryCodeKey] as String? ?? '';
    final phoneNumber =
        extra[LoginProvider.extraPhoneNumberKey] as String? ?? '';
    if (countryCode.isEmpty || phoneNumber.isEmpty) {
      return Routes.loginOrRegister;
    }
    return null;
  }

  /// Redirect for registerVerification route. Require valid extra (phone + country).
  /// Registration: must be unauthenticated. Change passcode: must be authenticated and
  /// phone/extra must match the signed-in user, with a 6-digit pending passcode.
  static String? registerVerification(
    BuildContext context,
    GoRouterState state,
  ) {
    final extra = state.extra;
    if (extra is! Map<String, dynamic>) {
      return Routes.loginOrRegister;
    }
    final countryCode =
        extra[LoginProvider.extraCountryCodeKey] as String? ?? '';
    final phoneNumber =
        extra[LoginProvider.extraPhoneNumberKey] as String? ?? '';
    if (countryCode.isEmpty || phoneNumber.isEmpty) {
      return Routes.loginOrRegister;
    }

    final authProvider = context.read<AuthProvider>();
    final purpose = extra[LoginProvider.extraVerificationPurposeKey] as String?;
    if (purpose == LoginProvider.purposeChangePasscode) {
      if (!authProvider.state.isAuthenticated ||
          authProvider.state.user == null) {
        return Routes.loginOrRegister;
      }
      final user = authProvider.state.user!;
      final normalizedExtraPhone = phoneNumber.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      final normalizedUserPhone = user.mobileNumber.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      if (countryCode.trim() != user.countryCode.trim() ||
          normalizedExtraPhone != normalizedUserPhone) {
        return Routes.home;
      }
      final pending = extra[LoginProvider.extraPendingPasscodeKey] as String?;
      if (pending == null || pending.length != 6) {
        return Routes.settings;
      }
      return null;
    }

    if (authProvider.state.isAuthenticated) {
      return Routes.home;
    }
    return null;
  }

  /// Change email → verify new-address OTP: require non-empty pending email.
  static String? changeEmailVerifyNewEmail(
    BuildContext context,
    GoRouterState state,
  ) {
    final authRedirect = isAuthenticated(context, state);
    if (authRedirect != null) return authRedirect;
    final extra = state.extra as Map<String, dynamic>?;
    final email = extra?[LoginProvider.extraPendingEmailKey] as String? ?? '';
    if (email.trim().isEmpty) {
      return Routes.changeEmailEnterNew;
    }
    return null;
  }

  /// Change phone → verify OTP: require navigation extra from enter-new screen.
  static String? changePhoneVerifyNew(
    BuildContext context,
    GoRouterState state,
  ) {
    final extra = state.extra;
    if (extra is! Map<String, dynamic>) {
      return Routes.changePhoneEnterNew;
    }
    final countryCode =
        extra[LoginProvider.extraCountryCodeKey] as String? ?? '';
    final phoneNumber =
        extra[LoginProvider.extraPhoneNumberKey] as String? ?? '';
    final maskedMobile =
        extra[LoginProvider.extraMaskedMobileKey] as String? ?? '';
    if (countryCode.isEmpty || phoneNumber.isEmpty || maskedMobile.isEmpty) {
      return Routes.changePhoneEnterNew;
    }
    return null;
  }
}
