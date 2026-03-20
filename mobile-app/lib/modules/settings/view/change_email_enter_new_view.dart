import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../modules/auth/providers/login_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common_back_button.dart';
import '../providers/change_email_form_provider.dart';

class ChangeEmailEnterNewView extends StatelessWidget {
  const ChangeEmailEnterNewView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChangeEmailFormProvider>();
    final l10n = context.l10n!;
    final theme = context.theme;
    // final isDark = context.isDarkMode;
    // final indicatorInactiveColor = theme.colorScheme.onSurface.withValues(
    //   alpha: isDark ? 0.16 : 0.20,
    // );

    return Scaffold(
      appBar: AppBar(
        leading: const CommonBackButton(),
        title: Text(
          l10n.changeEmail,
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
              // Row(
              //   children: [
              //     ...List.generate(4, (index) {
              //       final isActive = index < 2;
              //       return Padding(
              //         padding: EdgeInsetsDirectional.only(
              //           end: index < 3 ? 4 : 0,
              //         ),
              //         child: Container(
              //           width: isActive ? 44 : 14,
              //           height: 6,
              //           decoration: BoxDecoration(
              //             color: isActive
              //                 ? AppColors.primaryColor
              //                 : indicatorInactiveColor,
              //             borderRadius: BorderRadius.circular(16),
              //           ),
              //         ),
              //       );
              //     }),
              //   ],
              // ),
              // const SizedBox(height: 28),
              Text(
                l10n.enterNewEmailAddress,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.enterYourNewEmailAddressToReceiveOtp,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onChanged: provider.onEmailChanged,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: l10n.enterEmailAddressHint,
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primaryColor),
                  ),
                  errorText: provider.isSubmitted && !provider.isValidEmail
                      ? l10n.enterValidEmailAddress
                      : null,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  provider.markSubmitted();
                  if (!provider.canContinue) return;
                  context.push(
                    Routes.changeEmailVerifyNewEmail,
                    extra: {
                      LoginProvider.extraPendingEmailKey: provider.email.trim(),
                    },
                  );
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
