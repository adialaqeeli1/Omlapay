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
    return null;
  }
}
