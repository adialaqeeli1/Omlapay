import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../widgets/common_back_button.dart';

class ChangeDetailIntroView extends StatelessWidget {
  const ChangeDetailIntroView({
    super.key,
    required this.appBarTitle,
    required this.title,
    required this.description,
    required this.steps,
    required this.afterStepsNote,
    required this.continueLabel,
    required this.onContinue,
  });

  final String appBarTitle;
  final String title;
  final String description;
  final List<({String stepLabel, String stepText})> steps;
  final String afterStepsNote;
  final String continueLabel;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleColor = theme.colorScheme.onSurface.withValues(alpha: 0.68);

    return Scaffold(
      appBar: AppBar(
        leading: const CommonBackButton(),
        title: Text(
          appBarTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 26),
                      Text(
                        title,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontSize: 36 / 1.35,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: subtitleColor,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...steps.map((step) {
                        return _StepRow(
                          stepLabel: step.stepLabel,
                          stepText: step.stepText,
                        );
                      }),
                      const SizedBox(height: 8),
                      Text(
                        afterStepsNote,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: subtitleColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              FilledButton(
                onPressed: onContinue,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  continueLabel,
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

class _StepRow extends StatelessWidget {
  const _StepRow({required this.stepLabel, required this.stepText});

  final String stepLabel;
  final String stepText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                    text: '$stepLabel ',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: stepText,
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
}
