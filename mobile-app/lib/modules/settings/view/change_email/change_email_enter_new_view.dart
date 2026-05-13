import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../modules/auth/providers/login_provider.dart';
import '../../../../routes/app_router.dart';
import '../../../../widgets/common_text_field.dart';
import '../../providers/change_email_form_provider.dart';
import '../../services/change_email_service.dart';
import '../widgets/change_detail_back_to_intro.dart';
import '../widgets/change_detail_enter_new_view.dart';

class ChangeEmailEnterNewView extends StatelessWidget {
  const ChangeEmailEnterNewView({super.key, required this.changeEmailToken});

  final String changeEmailToken;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChangeEmailFormProvider>();
    final l10n = context.l10n!;
    final theme = context.theme;
    return ChangeDetailEnterNewView(
      appBarTitle: l10n.changeEmail,
      title: l10n.enterNewEmailAddress,
      subtitle: l10n.enterYourNewEmailAddressToReceiveOtp,
      onBackPressed: () => popToChangeEmailIntro(context),
      inputField: CommonTextField(
        fillColor: Colors.transparent,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        onChanged: provider.onEmailChanged,
        hintText: l10n.enterEmailAddressHint,
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
      validationErrorText: _errorTextForValidation(
        provider.validationError,
        l10n,
      ),
      continueLabel: l10n.continueButton,
      onContinue: () async {
        provider.markSubmitted();
        if (!provider.canContinue) return;
        try {
          final result = await ChangeEmailService.step4RequestNewEmail(
            changeEmailToken: changeEmailToken,
            newEmail: provider.normalizedEmail,
          );
          if (!context.mounted) return;
          final refreshedToken = result.changeEmailToken;
          final nextToken =
              (refreshedToken != null && refreshedToken.isNotEmpty)
              ? refreshedToken
              : changeEmailToken;
          context.push(
            Routes.changeEmailVerifyNewEmail,
            extra: {
              LoginProvider.extraPendingEmailKey: provider.normalizedEmail,
              LoginProvider.extraChangeEmailTokenKey: nextToken,
              LoginProvider.extraOtpExpirySecondsKey: result.otpExpirySeconds,
            },
          );
        } on AppException catch (e) {
          if (context.mounted) {
            SnackbarHelper.showError(context, e.localizedMessage(context.l10n));
          }
        }
      },
    );
  }

  String? _errorTextForValidation(
    ChangeEmailValidationError? error,
    dynamic l10n,
  ) {
    switch (error) {
      case ChangeEmailValidationError.empty:
        return l10n.pleaseEnterYourEmail;
      case ChangeEmailValidationError.invalid:
      // case ChangeEmailValidationError.sameAsCurrent:
      //   return l10n.enterValidEmailAddress;
      case null:
        return null;
    }
  }
}
