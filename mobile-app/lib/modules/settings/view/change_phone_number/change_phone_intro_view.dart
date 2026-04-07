import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../modules/auth/providers/login_provider.dart';
import '../../../../routes/app_router.dart';
import '../../../../widgets/common_back_button.dart';
import '../../services/change_phone_service.dart';

class ChangePhoneIntroView extends StatefulWidget {
  const ChangePhoneIntroView({super.key});

  @override
  State<ChangePhoneIntroView> createState() => _ChangePhoneIntroViewState();
}

class _ChangePhoneIntroViewState extends State<ChangePhoneIntroView> {
  bool _isLoading = false;

  Future<void> _onContinue() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final l10n = context.l10n!;
    try {
      final result = await ChangePhoneService.step1Request();
      if (!mounted) return;
      context.push(
        Routes.changePhoneVerifyCurrent,
        extra: {
          LoginProvider.extraMaskedMobileKey: result.maskedMobile,
          LoginProvider.extraOtpExpirySecondsKey: result.otpExpirySeconds,
        },
      );
    } on AppException catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, e.message);
    } catch (_) {
      if (!mounted) return;
      SnackbarHelper.showError(context, l10n.unknownError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final subtitleColor = theme.colorScheme.onSurface.withValues(alpha: 0.68);
    final steps = [
      (stepLabel: l10n.step1Label, stepText: l10n.changePhoneStep1),
      (stepLabel: l10n.step2Label, stepText: l10n.changePhoneStep2),
      (stepLabel: l10n.step3Label, stepText: l10n.changePhoneStep3),
      (stepLabel: l10n.step4Label, stepText: l10n.changePhoneStep4),
    ];

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
                      ...steps.map((step) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsetsDirectional.only(top: 6),
                                child: Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${step.stepLabel} ',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: step.stepText,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
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
                      }),
                      const SizedBox(height: 8),
                      Text(
                        l10n.changePhoneAfterStepsNote,
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
                onPressed: _isLoading ? null : _onContinue,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
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
