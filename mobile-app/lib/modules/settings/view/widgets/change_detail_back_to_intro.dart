import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/app_router.dart';

/// Pops the navigation stack until the change-phone intro screen is on top.
/// Falls back to a hard navigation if the intro isn't in the current stack
/// (e.g. after a deep link), so the user always lands on step 1.
void popToChangePhoneIntro(BuildContext context) =>
    _popToIntro(context, 'changePhoneIntro', Routes.changePhoneIntro);

/// Pops the navigation stack until the change-email intro screen is on top.
void popToChangeEmailIntro(BuildContext context) =>
    _popToIntro(context, 'changeEmailIntro', Routes.changeEmailIntro);

void _popToIntro(BuildContext context, String routeName, String fallbackPath) {
  final navigator = Navigator.of(context);
  var hasIntro = false;
  navigator.popUntil((route) {
    if (route.settings.name == routeName) {
      hasIntro = true;
      return true;
    }
    return route.isFirst;
  });
  if (!hasIntro && context.mounted) context.go(fallbackPath);
}
