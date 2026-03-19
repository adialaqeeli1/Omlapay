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
      return Routes.login;
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
        return Routes.login;
      }
      return null;
    }

    if (authProvider.state.isAuthenticated) {
      return Routes.home;
    }
    return null;
  }
}
