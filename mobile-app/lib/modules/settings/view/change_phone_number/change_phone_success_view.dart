import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../routes/app_router.dart';
import '../../../../widgets/change_detail_success_view.dart';

class ChangePhoneSuccessView extends StatelessWidget {
  const ChangePhoneSuccessView({super.key});

  void _goHome(BuildContext context) {
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    return ChangeDetailSuccessView(
      appBarTitle: l10n.changePhoneNumber,
      message: l10n.phoneNumberChangedSuccessfully,
      backHomeLabel: l10n.backHome,
      onBackHome: () => _goHome(context),
    );
  }
}
