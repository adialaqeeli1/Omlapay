import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../widgets/common_back_button.dart';

class ChangeDetailEnterNewView extends StatelessWidget {
  const ChangeDetailEnterNewView({
    super.key,
    required this.appBarTitle,
    required this.title,
    required this.subtitle,
    required this.inputField,
    required this.continueLabel,
    required this.onContinue,
    this.validationErrorText,
    this.isContinueLoading = false,
    this.onBackPressed,
  });

  final String appBarTitle;
  final String title;
  final String subtitle;
  final Widget inputField;
  final String continueLabel;
  final VoidCallback onContinue;
  final String? validationErrorText;
  final bool isContinueLoading;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBack = onBackPressed;

    final scaffold = Scaffold(
      appBar: AppBar(
        leading: CommonBackButton(onPressed: onBack),
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              inputField,
              if (validationErrorText != null) ...[
                const SizedBox(height: 8),
                Text(
                  validationErrorText!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const Spacer(),
              FilledButton(
                onPressed: isContinueLoading ? null : onContinue,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isContinueLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        continueLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );

    if (onBack == null) return scaffold;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        onBack();
      },
      child: scaffold,
    );
  }
}
