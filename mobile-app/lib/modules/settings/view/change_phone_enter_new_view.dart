import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../modules/auth/providers/login_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common_back_button.dart';
import '../providers/change_phone_form_provider.dart';

class ChangePhoneEnterNewView extends StatelessWidget {
  const ChangePhoneEnterNewView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChangePhoneFormProvider>();
    final l10n = context.l10n!;
    final theme = context.theme;
    final countryCode = provider.countryCode;

    return Scaffold(
      appBar: AppBar(
        leading: const CommonBackButton(),
        title: Text(
          l10n.changePhoneNumber,
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
                l10n.enterNewPhoneNumber,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.changePhoneStep2,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                      ),
                      child: Text(
                        countryCode,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        onChanged: provider.onPhoneChanged,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          hintText: l10n.phoneNumber,
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (provider.isSubmitted && !provider.isValidPhone) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.enterValidPhoneNumber,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const Spacer(),
              FilledButton(
                onPressed: () {
                  provider.markSubmitted();
                  if (!provider.canContinue) return;
                  context.push(
                    Routes.changePhoneVerifyNew,
                    extra: {
                      LoginProvider.extraCountryCodeKey: countryCode,
                      LoginProvider.extraPhoneNumberKey: provider.digitsOnly,
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
