import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../routes/app_router.dart';
import '../widgets/change_detail_intro_view.dart';

class ChangePhoneIntroView extends StatelessWidget {
  const ChangePhoneIntroView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    return ChangeDetailIntroView(
      appBarTitle: l10n.changePhoneNumber,
      title: l10n.stepsForChangingPhoneNumber,
      description: l10n.changePhoneStepsDescription,
      steps: [
        (stepLabel: l10n.step1Label, stepText: l10n.changePhoneStep1),
        (stepLabel: l10n.step2Label, stepText: l10n.changePhoneStep2),
        (stepLabel: l10n.step3Label, stepText: l10n.changePhoneStep3),
      ],
      afterStepsNote: l10n.changePhoneAfterStepsNote,
      continueLabel: l10n.continueButton,
      onContinue: () => context.push(Routes.changePhoneEnterNew),
    );
  }
}
