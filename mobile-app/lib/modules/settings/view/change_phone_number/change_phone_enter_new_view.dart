import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../modules/auth/providers/login_provider.dart';
import '../../../../routes/app_router.dart';
import '../../../../widgets/common_text_field.dart';
import '../../providers/change_phone_form_provider.dart';
import '../widgets/change_detail_enter_new_view.dart';

class ChangePhoneEnterNewView extends StatelessWidget {
  const ChangePhoneEnterNewView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChangePhoneFormProvider>();
    final l10n = context.l10n!;
    final theme = context.theme;
    final countryCode = provider.currentPhoneCode;
    final isDark = context.isDarkMode;
    final phoneGroupBackground = isDark
        ? AppColors.darkCardColor.withValues(alpha: 0.92)
        : theme.colorScheme.onSurface.withValues(alpha: 0.05);
    final phoneFieldBorderColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.16 : 0.10,
    );

    return ChangeDetailEnterNewView(
      appBarTitle: l10n.changePhoneNumber,
      title: l10n.enterNewPhoneNumber,
      subtitle: l10n.changePhoneEnterNewSubtitle,
      inputField: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: true,
                onSelect: provider.updateCountry,
                countryListTheme: CountryListThemeData(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  backgroundColor: theme.scaffoldBackgroundColor,
                  textStyle: theme.textTheme.titleMedium,
                  searchTextStyle: theme.textTheme.bodyLarge,
                ),
              );
            },
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: phoneGroupBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    provider.currentFlagEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    provider.currentPhoneCode,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CommonTextField(
              fillColor: isDark
                  ? AppColors.darkBackground
                  : AppColors.lightBackground,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15),
              ],
              maxLength: 15,
              hintText: l10n.phoneNumber,
              onChanged: provider.onPhoneChanged,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: phoneFieldBorderColor,
                  width: 1,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: AppColors.primaryColor),
              ),
            ),
          ),
        ],
      ),
      validationErrorText: _errorTextForValidation(
        provider.validationError,
        l10n,
      ),
      continueLabel: l10n.continueButton,
      isContinueLoading: provider.isSubmitting,
      onContinue: () async {
        try {
          final result = await provider.submitRequestChange();
          if (!context.mounted || result == null) return;
          context.push(
            Routes.changePhoneVerifyNew,
            extra: {
              LoginProvider.extraCountryCodeKey: countryCode,
              LoginProvider.extraPhoneNumberKey: provider.digitsOnly,
              LoginProvider.extraMaskedMobileKey: result.maskedMobile,
              LoginProvider.extraOtpExpirySecondsKey: result.otpExpirySeconds,
            },
          );
        } on AppException catch (e) {
          if (!context.mounted) return;
          SnackbarHelper.showError(context, e.message);
        } catch (_) {
          if (!context.mounted) return;
          SnackbarHelper.showError(context, l10n.unknownError);
        }
      },
    );
  }

  String? _errorTextForValidation(
    ChangePhoneValidationError? error,
    dynamic l10n,
  ) {
    switch (error) {
      case ChangePhoneValidationError.empty:
        return l10n.enterValidPhoneNumber;
      case ChangePhoneValidationError.invalidLength:
        return l10n.enterValidPhoneNumber;
      case ChangePhoneValidationError.sameAsCurrent:
        return l10n.enterValidPhoneNumber;
      case null:
        return null;
    }
  }
}
