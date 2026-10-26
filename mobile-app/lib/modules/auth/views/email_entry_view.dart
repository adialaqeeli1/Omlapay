import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common_back_button.dart';
import '../../../widgets/common_text_field.dart';
import '../providers/email_verification_provider.dart';

class EmailEntryView extends StatelessWidget {
  const EmailEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final isDark = context.isDarkMode;
    final provider = context.watch<EmailVerificationProvider>();

    final emailError = provider.emailError;
    String? errorText;
    if (emailError == 'empty') {
      errorText = l10n.kycEmailRequiredError;
    } else if (emailError == 'invalid') {
      errorText = l10n.kycEmailInvalidError;
    }

    return Scaffold(
      appBar: AppBar(
        leading: const CommonBackButton(),
        title: Text(
          l10n.kycEnterEmail,
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
                l10n.kycWhatsYourEmail,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.kycEmailSubtitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              CommonTextField(
                fillColor: Colors.transparent,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                // Keep email text left-to-right even under an RTL/Arabic locale.
                textDirection: TextDirection.ltr,
                onChanged: provider.setEmail,
                hintText: l10n.kycEmailHint,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: AppColors.primaryColor),
                ),
              ),
              if (errorText != null) ...[
                const SizedBox(height: 8),
                Text(
                  errorText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const Spacer(),
              FilledButton(
                onPressed: provider.isRequestingOtp
                    ? null
                    : () => _onContinue(context),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor:
                      isDark ? AppColors.darkSurface : AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: provider.isRequestingOtp
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        l10n.continueButton,
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
  }

  Future<void> _onContinue(BuildContext context) async {
    final provider = context.read<EmailVerificationProvider>();
    provider.markEmailSubmitted();
    if (!provider.isEmailValid) return;

    try {
      await provider.requestOtp();
      if (!context.mounted) return;
      final verified = await context.push<bool>(
        Routes.emailVerifyOtp,
        extra: provider,
      );
      if (!context.mounted) return;
      if (verified == true) {
        context.pop(true);
      }
    } catch (e) {
      if (!context.mounted) return;
      SnackbarHelper.showError(context, e.toString());
    }
  }
}
