import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../app_router.dart';

class AuthMiddleware {
  static String? isAuthenticated(BuildContext context, GoRouterState state) {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.state.isAuthenticated) {
      return Routes.hardLogin;
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
}
