import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common_back_button.dart';

class ChangePhoneIntroView extends StatelessWidget {
  const ChangePhoneIntroView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final subtitleColor = theme.colorScheme.onSurface.withValues(alpha: 0.68);

    Widget stepRow(String step, String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsetsDirectional.only(top: 6),
              child: Icon(Icons.circle, size: 6, color: AppColors.primaryColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$step ',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: text,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const CommonBackButton(),
        title: Text(
          l10n.changePhoneNumber,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 26),
              Text(
                l10n.stepsForChangingPhoneNumber,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontSize: 36 / 1.35,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.changePhoneStepsDescription,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: subtitleColor,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),
              stepRow(l10n.step1Label, l10n.changePhoneStep1),
              stepRow(l10n.step2Label, l10n.changePhoneStep2),
              stepRow(l10n.step3Label, l10n.changePhoneStep3),
              const SizedBox(height: 8),
              Text(
                l10n.changePhoneAfterStepsNote,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: subtitleColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.push(Routes.changePhoneVerifyCurrent),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  l10n.continueButton,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
