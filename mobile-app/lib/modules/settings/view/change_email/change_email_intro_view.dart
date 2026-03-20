import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../routes/app_router.dart';
import '../widgets/change_detail_intro_view.dart';

class ChangeEmailIntroView extends StatelessWidget {
  const ChangeEmailIntroView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    return ChangeDetailIntroView(
      appBarTitle: l10n.changeEmail,
      title: l10n.stepsForChangingEmail,
      description: l10n.changeEmailStepsDescription,
      steps: [
        (stepLabel: l10n.step1Label, stepText: l10n.changeEmailStep1),
        (stepLabel: l10n.step2Label, stepText: l10n.changeEmailStep2),
        (stepLabel: l10n.step3Label, stepText: l10n.changeEmailStep3),
        (stepLabel: l10n.step4Label, stepText: l10n.changeEmailStep4),
      ],
      afterStepsNote: l10n.changeEmailAfterStepsNote,
      continueLabel: l10n.continueButton,
      onContinue: () => context.push(Routes.changeEmailVerifyPhone),
    );
  }
}
