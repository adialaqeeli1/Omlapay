import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/change_detail_success_view.dart';

/// Shown after SMS verification completes in the settings → change passcode flow.
class ChangePasscodeSuccessView extends StatelessWidget {
  const ChangePasscodeSuccessView({super.key});

  void _goHome(BuildContext context) {
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    return ChangeDetailSuccessView(
      appBarTitle: l10n.changePasscode,
      message: l10n.passcodeChangedSuccessfully,
      backHomeLabel: l10n.backHome,
      onBackHome: () => _goHome(context),
    );
  }
}
