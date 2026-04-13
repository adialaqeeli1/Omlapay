import 'package:flutter/material.dart';
import 'package:country_codes/country_codes.dart';
import 'package:country_picker/country_picker.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:go_router/go_router.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../routes/app_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/kyc_status_provider.dart';
import '../../../widgets/common_back_button.dart';
import '../providers/kyc_verification_provider.dart';
import '../utils/kyc_status.dart';
import '../utils/kyc_verification_entry_source.dart';

class KycVerificationView extends StatefulWidget {
  const KycVerificationView({super.key, required this.entrySource});

  final KycVerificationEntrySource entrySource;

  @override
  State<KycVerificationView> createState() => _KycVerificationViewState();
}

class _KycVerificationViewState extends State<KycVerificationView> {
  /// When true, forces the form to show regardless of KYC status
  /// (e.g. when user taps "Retry Verification" from rejected state).
  bool _forceShowForm = false;

  final FormGroup _form = FormGroup({
    'firstName': FormControl<String>(validators: [Validators.required]),
    'lastName': FormControl<String>(validators: [Validators.required]),
    'dateOfBirth': FormControl<String>(validators: [Validators.required]),
    'residentialCountry': FormControl<String>(
      validators: [Validators.required],
    ),
    'documentCountry': FormControl<String>(validators: [Validators.required]),
    'city': FormControl<String>(validators: [Validators.required]),
    'address': FormControl<String>(validators: [Validators.required]),
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final kycStatusProvider = context.watch<KycStatusProvider>();
    final kycStatus = kycStatusProvider.kycStatus;

    return Scaffold(
      appBar: AppBar(
        leading: const CommonBackButton(),
        title: Text(
          l10n.kycVerification,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: _forceShowForm
            ? _KycFormBody(form: _form, entrySource: widget.entrySource)
            : switch (kycStatus) {
                KycStatus.pending => _KycPendingBody(),
                KycStatus.rejected => _KycRejectedBody(
                  rejectionReason: kycStatusProvider.rejectionReason,
                  onRetry: () => setState(() => _forceShowForm = true),
                ),
                _ => _KycFormBody(form: _form, entrySource: widget.entrySource),
              },
      ),
    );
  }
}

/// Shown when KYC is submitted and under review.
class _KycPendingBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hourglass_top_rounded,
              size: 64,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.kyc_submitted_under_review,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.kyc_pending_subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when KYC is rejected — displays reason and retry button.
class _KycRejectedBody extends StatelessWidget {
  const _KycRejectedBody({
    required this.rejectionReason,
    required this.onRetry,
  });

  final String? rejectionReason;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final isDark = context.isDarkMode;

    final message = rejectionReason != null && rejectionReason!.isNotEmpty
        ? l10n.kyc_rejected_with_reason(rejectionReason!)
        : l10n.kyc_rejected;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cancel_outlined,
              size: 64,
              color: AppColors.kycBannerAccent,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: isDark
                      ? AppColors.darkSurface
                      : AppColors.white,
                ),
                child: Text(l10n.kyc_retry_button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The original KYC form for users who haven't started verification.
class _KycFormBody extends StatelessWidget {
  const _KycFormBody({required this.form, required this.entrySource});

  final FormGroup form;
  final KycVerificationEntrySource entrySource;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final isDark = context.isDarkMode;
    final provider = context.watch<KycVerificationProvider>();

    return ReactiveForm(
      formGroup: form,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 720;
                    final fieldWidth = isWide
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth;

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: fieldWidth,
                          child: _KycTextField(
                            formControlName: 'firstName',
                            label: l10n.kycFirstNameLabel,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _KycTextField(
                            formControlName: 'lastName',
                            label: l10n.kycLastNameLabel,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _KycDateField(
                            formControlName: 'dateOfBirth',
                            label: l10n.kycDateOfBirthLabel,
                            hint: l10n.kycSelectDateHint,
                            form: form,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _KycCountryField(
                            formControlName: 'residentialCountry',
                            label: l10n.kycResidentialCountryLabel,
                            hint: l10n.kycCountryCodeHint,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _KycCountryField(
                            formControlName: 'documentCountry',
                            label: l10n.kycDocumentCountryLabel,
                            hint: l10n.kycCountryCodeHint,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _KycTextField(
                            formControlName: 'city',
                            label: l10n.kycCityLabel,
                          ),
                        ),
                        SizedBox(
                          width: constraints.maxWidth,
                          child: _KycTextField(
                            formControlName: 'address',
                            label: l10n.kycAddressLabel,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            ReactiveFormConsumer(
              builder: (context, formState, child) {
                return SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: formState.valid
                        ? () async {
                            FocusScope.of(context).unfocus();
                            final kycProvider = context
                                .read<KycVerificationProvider>();
                            final formData = kycProvider.validateForm(form);
                            if (formData == null) return;

                            // Skip email verification if user already has an email
                            final user = context
                                .read<AuthProvider>()
                                .state
                                .user;
                            final hasEmail =
                                user?.email != null && user!.email!.isNotEmpty;

                            if (!hasEmail) {
                              final emailVerified = await context.push<bool>(
                                Routes.emailEntry,
                              );
                              if (!context.mounted || emailVerified != true) {
                                return;
                              }
                            }

                            // Email verified — launch SumSub
                            try {
                              final result = await kycProvider.launchSumSub(
                                firstName: formData.firstName,
                                lastName: formData.lastName,
                                residentialCountry: formData.residentialCountry,
                                documentCountry: formData.documentCountry,
                                city: formData.city,
                                address: formData.address,
                                dob: formData.dob,
                                locale: Localizations.localeOf(context),
                                startFailedFallback: l10n.requestFailed,
                                successFallback: l10n.kycStartedSuccess,
                                authProvider: context.read<AuthProvider>(),
                                kycStatusProvider: context
                                    .read<KycStatusProvider>(),
                              );
                              if (!context.mounted) return;
                              if (result.message.isNotEmpty) {
                                SnackbarHelper.showSuccess(
                                  context,
                                  result.message,
                                );
                              }
                              if (result.shouldNavigateBack) {
                                context.go(entrySource.sourceRoute);
                              }
                            } catch (e) {
                              if (!context.mounted) return;
                              SnackbarHelper.showError(context, e.toString());
                            }
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: isDark
                          ? AppColors.darkSurface
                          : AppColors.white,
                      disabledBackgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      disabledForegroundColor: theme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                    child: provider.isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.kycSubmitButton),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _KycTextField extends StatelessWidget {
  const _KycTextField({required this.formControlName, required this.label});

  final String formControlName;
  final String label;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final isDark = context.isDarkMode;

    return ReactiveTextField<String>(
      formControlName: formControlName,
      validationMessages: {
        ValidationMessage.required: (_) => l10n.kycRequiredFieldError,
      },
      textInputAction: TextInputAction.next,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.35),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

class _KycDateField extends StatelessWidget {
  const _KycDateField({
    required this.formControlName,
    required this.label,
    required this.hint,
    required this.form,
  });

  final String formControlName;
  final String label;
  final String hint;
  final FormGroup form;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final isDark = context.isDarkMode;

    return ReactiveTextField<String>(
      formControlName: formControlName,
      readOnly: true,
      validationMessages: {
        ValidationMessage.required: (_) => l10n.kycRequiredFieldError,
      },
      onTap: (_) async {
        final now = DateTime.now();
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime(now.year - 18, now.month, now.day),
          firstDate: DateTime(1900),
          lastDate: now,
        );
        if (!context.mounted || pickedDate == null) {
          return;
        }
        final formatted =
            '${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.year}';
        // final form = ReactiveForm.of(context) as FormGroup;
        form.control(formControlName).value = formatted;
      },
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: const Icon(Icons.calendar_today_outlined),
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.35),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

class _KycCountryField extends StatelessWidget {
  const _KycCountryField({
    required this.formControlName,
    required this.label,
    required this.hint,
  });

  final String formControlName;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final isDark = context.isDarkMode;

    return ReactiveTextField<String>(
      formControlName: formControlName,
      readOnly: true,
      validationMessages: {
        ValidationMessage.required: (_) => l10n.kycRequiredFieldError,
      },
      onTap: (_) {
        showCountryPicker(
          context: context,
          showPhoneCode: false,
          countryListTheme: CountryListThemeData(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
            textStyle: theme.textTheme.titleMedium,
            searchTextStyle: theme.textTheme.bodyLarge,
          ),
          onSelect: (country) {
            final alpha3 =
                CountryCodes.detailsFromAlpha2(
                  country.countryCode,
                ).alpha3Code ??
                country.countryCode;
            final form = ReactiveForm.of(context) as FormGroup;
            form.control(formControlName).value = alpha3;
          },
        );
      },
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: const Icon(Icons.keyboard_arrow_down),
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.35),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}
