import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/theme/theme.dart';
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
    final countryCode = provider.countryCode;

    return ChangeDetailEnterNewView(
      appBarTitle: l10n.changePhoneNumber,
      title: l10n.enterNewPhoneNumber,
      subtitle: l10n.changePhoneStep2,
      inputField: CommonTextField(
        fillColor: Colors.transparent,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ],
        maxLength: 9,
        hintText: l10n.phoneNumber,
        onChanged: provider.onPhoneChanged,
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
        prefixIcon: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
                child: Text(
                  countryCode,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      validationErrorText: _errorTextForValidation(
        provider.validationError,
        l10n,
      ),
      continueLabel: l10n.continueButton,
      onContinue: () {
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
        return l10n.phoneNumberMustBe9Digits;
      case ChangePhoneValidationError.sameAsCurrent:
        return l10n.enterValidPhoneNumber;
      case null:
        return null;
    }
  }
}
