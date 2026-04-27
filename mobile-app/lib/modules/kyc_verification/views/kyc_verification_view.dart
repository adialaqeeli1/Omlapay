import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_codes/country_codes.dart';
import 'package:country_picker/country_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:go_router/go_router.dart';

import '../../../core/constants/constants.dart';
import '../../../core/extentions/context_extensions.dart';
import '../../../core/services/storage_helper.dart';
import '../../../core/utils/app_exception.dart';
import '../../../routes/app_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/kyc_status_provider.dart';
import '../../../widgets/common_back_button.dart';
import '../../../widgets/common_bottom_sheet.dart';
import '../../../widgets/permission_dialog.dart';
import '../models/kyc_rejection_details_response.dart';
import '../providers/kyc_verification_provider.dart';
import '../utils/kyc_image_slot.dart';
import '../utils/kyc_status.dart';
import '../utils/kyc_verification_entry_source.dart';

/// User's choice from the per-tile "View / Pick from gallery / Take photo"
/// action sheet.
enum _KycDocAction { view, gallery, camera }

/// Opens the 3-action sheet for a single KYC document slot. Returns the
/// chosen `_KycDocAction`, or `null` if the sheet was dismissed.
Future<_KycDocAction?> _showKycDocumentActionSheet(BuildContext context) {
  final l10n = context.l10n!;
  return showModalBottomSheet<_KycDocAction>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => CommonBottomSheet(
      title: l10n.kycDocumentsReviewTitle,
      childrens: [
        ListTile(
          leading: const Icon(Icons.visibility_outlined),
          title: Text(l10n.kycDocumentActionView),
          onTap: () => Navigator.of(sheetContext).pop(_KycDocAction.view),
        ),
        ListTile(
          leading: const Icon(Icons.photo_library_outlined),
          title: Text(l10n.kycDocumentActionPickGallery),
          onTap: () => Navigator.of(sheetContext).pop(_KycDocAction.gallery),
        ),
        ListTile(
          leading: const Icon(Icons.photo_camera_outlined),
          title: Text(l10n.kycDocumentActionTakePhoto),
          onTap: () => Navigator.of(sheetContext).pop(_KycDocAction.camera),
        ),
      ],
    ),
  );
}

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

  /// Previously uploaded KYC documents (front / back / selfie). Populated when
  /// the user retries after a rejection; shown below the form for reference.
  KycDocuments? _previousDocuments;

  /// Locally-picked replacement images for the retry flow. `null` means "keep
  /// the previously uploaded image". These live in `State` so they are
  /// discarded automatically when the user leaves the retry screen.
  XFile? _pickedFront;
  XFile? _pickedBack;
  XFile? _pickedFace;

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

  Future<void> _handleRetry() async {
    final provider = context.read<KycVerificationProvider>();
    final details = await provider.loadRejectionDetails();
    if (!mounted) return;
    if (details?.previousData != null) {
      _prefillForm(details!.previousData!);
    }
    setState(() {
      _previousDocuments = details?.documents;
      _forceShowForm = true;
    });
  }

  void _prefillForm(KycPreviousData data) {
    _form.control('firstName').value = data.firstName ?? '';
    _form.control('lastName').value = data.lastName ?? '';
    _form.control('city').value = data.city ?? '';
    _form.control('address').value = data.address ?? '';
    _form.control('residentialCountry').value =
        data.country?.toUpperCase() ?? '';
    _form.control('documentCountry').value =
        data.nationality?.toUpperCase() ?? '';

    final formattedDob = _isoToDisplayDate(data.dob);
    if (formattedDob != null) {
      _form.control('dateOfBirth').value = formattedDob;
    }
  }

  /// Converts ISO `YYYY-MM-DD` to the form's `MM/DD/YYYY` display format.
  String? _isoToDisplayDate(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final parts = iso.split('-');
    if (parts.length != 3) return null;
    final year = parts[0];
    final month = parts[1].padLeft(2, '0');
    final day = parts[2].padLeft(2, '0');
    return '$month/$day/$year';
  }

  /// Handles a tap on a single document tile in the retry flow. Opens the
  /// 3-action sheet (View / Gallery / Camera), then either opens the full
  /// screen viewer or dispatches the picker flow based on the choice.
  Future<void> _handleSlotTap(KycImageSlot slot) async {
    final l10n = context.l10n!;
    final action = await _showKycDocumentActionSheet(context);
    if (!mounted || action == null) return;

    switch (action) {
      case _KycDocAction.view:
        final currentFile = switch (slot) {
          KycImageSlot.front => _pickedFront,
          KycImageSlot.back => _pickedBack,
          KycImageSlot.selfie => _pickedFace,
        };
        final currentUrl = switch (slot) {
          KycImageSlot.front => _previousDocuments?.frontUrl,
          KycImageSlot.back => _previousDocuments?.backUrl,
          KycImageSlot.selfie => _previousDocuments?.faceUrl,
        };
        if (currentFile == null && (currentUrl == null || currentUrl.isEmpty)) {
          // Nothing to view yet — silently no-op. The user will see the
          // "Add photo" placeholder on the tile and can tap again to pick.
          return;
        }
        final label = switch (slot) {
          KycImageSlot.front => l10n.kycDocumentFrontLabel,
          KycImageSlot.back => l10n.kycDocumentBackLabel,
          KycImageSlot.selfie => l10n.kycDocumentSelfieLabel,
        };
        _openFullScreenImage(
          context,
          url: currentFile == null ? currentUrl : null,
          file: currentFile,
          label: label,
        );

      case _KycDocAction.gallery:
        await _pickImageForSlot(slot, source: ImageSource.gallery);
      case _KycDocAction.camera:
        await _pickImageForSlot(slot, source: ImageSource.camera);
    }
  }

  Future<void> _pickImageForSlot(
    KycImageSlot slot, {
    required ImageSource source,
  }) async {
    final provider = context.read<KycVerificationProvider>();
    final l10n = context.l10n!;
    try {
      final file = await provider.pickKycImage(source: source, slot: slot);
      if (!mounted) return;
      if (file == null) {
        // null == user cancelled OR OS denied permission. Show the
        // permission-denied dialog only for the camera path; for gallery,
        // a cancel is common and a prompt would be noisy.
        if (source == ImageSource.camera) {
          await showDialog<void>(
            context: context,
            builder: (dialogContext) => PermissionDialog(
              title: l10n.kycPermissionDeniedTitle,
              message: l10n.kycPermissionDeniedBody,
              allowLabel: l10n.kycOpenSettings,
              onOpenSettings: () {
                Navigator.of(dialogContext).pop();
                ph.openAppSettings();
              },
              onDoNotAllow: () => Navigator.of(dialogContext).pop(),
            ),
          );
        }
        return;
      }
      setState(() {
        switch (slot) {
          case KycImageSlot.front:
            _pickedFront = file;
          case KycImageSlot.back:
            _pickedBack = file;
          case KycImageSlot.selfie:
            _pickedFace = file;
        }
      });
    } on AppException {
      if (!mounted) return;
      SnackbarHelper.showError(context, l10n.kycDocumentPickFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final kycStatusProvider = context.watch<KycStatusProvider>();
    final kycStatus = kycStatusProvider.kycStatus;
    final isLoadingPrefill = context
        .watch<KycVerificationProvider>()
        .isLoadingRejectionDetails;

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
            ? _KycFormBody(
                form: _form,
                entrySource: widget.entrySource,
                previousDocuments: _previousDocuments,
                isRejectedRetry: kycStatus == KycStatus.rejected,
                pickedFront: _pickedFront,
                pickedBack: _pickedBack,
                pickedFace: _pickedFace,
                onTapSlot: _handleSlotTap,
              )
            : switch (kycStatus) {
                KycStatus.pending => _KycPendingBody(),
                KycStatus.rejected => _KycRejectedBody(
                  rejectionReason: kycStatusProvider.rejectionReason,
                  onRetry: _handleRetry,
                  isLoading: isLoadingPrefill,
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
    this.isLoading = false,
  });

  final String? rejectionReason;
  final VoidCallback onRetry;
  final bool isLoading;

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
                onPressed: isLoading ? null : onRetry,
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
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.kyc_retry_button),
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
  const _KycFormBody({
    required this.form,
    required this.entrySource,
    this.previousDocuments,
    this.isRejectedRetry = false,
    this.pickedFront,
    this.pickedBack,
    this.pickedFace,
    this.onTapSlot,
  });

  final FormGroup form;
  final KycVerificationEntrySource entrySource;

  /// Uploaded documents from a previous rejected submission.
  final KycDocuments? previousDocuments;

  /// When true, submitting the form calls `kyc/resubmit` instead of the
  /// SumSub-start flow (used only after a rejected KYC).
  final bool isRejectedRetry;

  /// Locally-picked replacements. Only used when `isRejectedRetry` is true.
  final XFile? pickedFront;
  final XFile? pickedBack;
  final XFile? pickedFace;

  /// Invoked when the user taps a document tile in the review section.
  /// Must be non-null when `isRejectedRetry` is true.
  final ValueChanged<KycImageSlot>? onTapSlot;

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
                // Top inset gives the first field's floating outline label
                // room to render — without it the label extends above the
                // scroll viewport and gets clipped.
                physics: ClampingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.only(top: 8),
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
                        if (isRejectedRetry && onTapSlot != null)
                          SizedBox(
                            width: constraints.maxWidth,
                            child: _KycDocumentsReviewSection(
                              documents: previousDocuments,
                              pickedFront: pickedFront,
                              pickedBack: pickedBack,
                              pickedFace: pickedFace,
                              onTapSlot: onTapSlot!,
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

                            // Rejected retry: skip email + SumSub, just resubmit.
                            if (isRejectedRetry) {
                              try {
                                final result = await kycProvider.resubmitKyc(
                                  firstName: formData.firstName,
                                  lastName: formData.lastName,
                                  residentialCountry:
                                      formData.residentialCountry,
                                  documentCountry: formData.documentCountry,
                                  city: formData.city,
                                  address: formData.address,
                                  dob: formData.dob,
                                  successFallback: l10n.kycStartedSuccess,
                                  authProvider: context.read<AuthProvider>(),
                                  kycStatusProvider: context
                                      .read<KycStatusProvider>(),
                                  idFront: pickedFront,
                                  idBack: pickedBack,
                                  selfie: pickedFace,
                                );
                                if (!context.mounted) return;
                                if (result.success &&
                                    result.message.isNotEmpty) {
                                  SnackbarHelper.showSuccess(
                                    context,
                                    result.message,
                                  );
                                }
                                if (result.success) {
                                  context.go(entrySource.sourceRoute);
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                SnackbarHelper.showError(context, e.toString());
                              }
                              return;
                            }

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

  Future<void> _openDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (_) => _KycDateInputDialog(
        initialDate: DateTime(now.year - 18, now.month, now.day),
        firstDate: DateTime(1900),
        lastDate: now,
      ),
    );
    if (!context.mounted || pickedDate == null) {
      return;
    }
    final formatted =
        '${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.year}';
    form.control(formControlName).value = formatted;
  }

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
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: const [_DateInputFormatter()],
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today_outlined),
          onPressed: () => _openDatePicker(context),
        ),
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

/// Auto-inserts `/` separators as the user types digits for a `M(M)/D(D)/YYYY`
/// date. The month length is inferred from the first digit (0/1 → 2-digit
/// month, 2-9 → 1-digit) and the day length from the first day digit
/// (0/1/2/3 → 2-digit, 4-9 → 1-digit), so both `04272008` and `4272008`
/// format correctly. Year is capped at 4 digits; excess input is dropped.
class _DateInputFormatter extends TextInputFormatter {
  const _DateInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue();
    }

    final monthLen = (digits[0] == '0' || digits[0] == '1') ? 2 : 1;
    final actualMonthLen = digits.length < monthLen ? digits.length : monthLen;

    var actualDayLen = 0;
    if (digits.length > actualMonthLen) {
      final firstDay = digits[actualMonthLen];
      final dayLen =
          (firstDay == '0' ||
              firstDay == '1' ||
              firstDay == '2' ||
              firstDay == '3')
          ? 2
          : 1;
      final remaining = digits.length - actualMonthLen;
      actualDayLen = remaining < dayLen ? remaining : dayLen;
    }

    final yearStart = actualMonthLen + actualDayLen;
    final remainingForYear = digits.length - yearStart;
    final actualYearLen = remainingForYear < 4 ? remainingForYear : 4;

    final buf = StringBuffer();
    buf.write(digits.substring(0, actualMonthLen));
    if (actualDayLen > 0) {
      buf.write('/');
      buf.write(
        digits.substring(actualMonthLen, actualMonthLen + actualDayLen),
      );
    }
    if (actualYearLen > 0) {
      buf.write('/');
      buf.write(digits.substring(yearStart, yearStart + actualYearLen));
    }

    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
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

Map<String, String> _authImageHeaders() {
  final token = StorageService.getString(AppConstants.tokenKey);
  return {
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };
}

void _openFullScreenImage(
  BuildContext context, {
  String? url,
  XFile? file,
  required String label,
}) {
  assert(url != null || file != null, 'Provide either url or file');
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      pageBuilder: (_, _, _) =>
          _KycDocumentFullScreenView(url: url, file: file, label: label),
    ),
  );
}

/// Documents review for the retry flow: shows selfie, ID front, ID back.
/// Each tile is tappable and either:
///   • renders the user's freshly picked `XFile` with a "Changed" pill, or
///   • renders the previously uploaded remote image, or
///   • renders an "Add photo" placeholder when nothing exists yet.
class _KycDocumentsReviewSection extends StatelessWidget {
  const _KycDocumentsReviewSection({
    required this.documents,
    required this.pickedFront,
    required this.pickedBack,
    required this.pickedFace,
    required this.onTapSlot,
  });

  final KycDocuments? documents;
  final XFile? pickedFront;
  final XFile? pickedBack;
  final XFile? pickedFace;
  final ValueChanged<KycImageSlot> onTapSlot;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;

    final frontUrl = documents?.frontUrl;
    final backUrl = documents?.backUrl;
    final faceUrl = documents?.faceUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          l10n.kycDocumentsReviewTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: _KycSelfieAvatar(
            file: pickedFace,
            url: faceUrl,
            label: l10n.kycDocumentSelfieLabel,
            isChanged: pickedFace != null,
            onTap: () => onTapSlot(KycImageSlot.selfie),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            l10n.kycDocumentSelfieLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _KycDocumentPreview(
                label: l10n.kycDocumentFrontLabel,
                file: pickedFront,
                url: frontUrl,
                isChanged: pickedFront != null,
                onTap: () => onTapSlot(KycImageSlot.front),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KycDocumentPreview(
                label: l10n.kycDocumentBackLabel,
                file: pickedBack,
                url: backUrl,
                isChanged: pickedBack != null,
                onTap: () => onTapSlot(KycImageSlot.back),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KycSelfieAvatar extends StatelessWidget {
  const _KycSelfieAvatar({
    required this.file,
    required this.url,
    required this.label,
    required this.isChanged,
    required this.onTap,
  });

  final XFile? file;
  final String? url;
  final String label;
  final bool isChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = context.isDarkMode;
    final hasImage = file != null || (url != null && url!.isNotEmpty);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: !hasImage
                  ? _AddPhotoPlaceholder(circular: true)
                  : file != null
                  ? Image.file(File(file!.path), fit: BoxFit.cover)
                  : CachedNetworkImage(
                      imageUrl: url!,
                      httpHeaders: _authImageHeaders(),
                      fit: BoxFit.cover,
                      placeholder: (context, _) => Container(
                        color: isDark
                            ? AppColors.darkSurface
                            : theme.colorScheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, _, _) => Container(
                        color: isDark
                            ? AppColors.darkSurface
                            : theme.colorScheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
            ),
          ),
          if (isChanged)
            PositionedDirectional(bottom: -4, end: -4, child: _ChangedPill()),
        ],
      ),
    );
  }
}

class _KycDocumentPreview extends StatelessWidget {
  const _KycDocumentPreview({
    required this.label,
    required this.file,
    required this.url,
    required this.isChanged,
    required this.onTap,
  });

  final String label;
  final XFile? file;
  final String? url;
  final bool isChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final isDark = context.isDarkMode;
    final hasImage = file != null || (url != null && url!.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.25),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: !hasImage
                        ? _AddPhotoPlaceholder(circular: false)
                        : file != null
                        ? Image.file(File(file!.path), fit: BoxFit.contain)
                        : CachedNetworkImage(
                            imageUrl: url!,
                            httpHeaders: _authImageHeaders(),
                            fit: BoxFit.contain,
                            placeholder: (context, _) => const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, _, _) => Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_outlined,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    l10n.kycDocumentLoadFailed,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              if (isChanged)
                PositionedDirectional(top: 8, end: 8, child: _ChangedPill()),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChangedPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        l10n.kycDocumentChangedBadge,
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AddPhotoPlaceholder extends StatelessWidget {
  const _AddPhotoPlaceholder({required this.circular});

  final bool circular;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final fg = theme.colorScheme.onSurfaceVariant;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: circular ? null : BorderRadius.circular(12),
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined, color: fg, size: 28),
          const SizedBox(height: 6),
          Text(
            l10n.kycDocumentAddPhoto,
            style: theme.textTheme.bodySmall?.copyWith(color: fg),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _KycDocumentFullScreenView extends StatelessWidget {
  const _KycDocumentFullScreenView({this.url, this.file, required this.label})
    : assert(url != null || file != null);

  final String? url;
  final XFile? file;
  final String label;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;

    final Widget image = file != null
        ? Image.file(File(file!.path), fit: BoxFit.contain)
        : CachedNetworkImage(
            imageUrl: url!,
            httpHeaders: _authImageHeaders(),
            fit: BoxFit.contain,
            placeholder: (context, _) => const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            errorWidget: (context, _, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white70,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.kycDocumentLoadFailed,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: InteractiveViewer(minScale: 1, maxScale: 5, child: image),
        ),
      ),
    );
  }
}

/// Replacement for `showDatePicker`'s built-in input mode that respects
/// [_DateInputFormatter]. The dialog shows an auto-formatting text field
/// at the top and a `CalendarDatePicker` below; the two stay in sync —
/// typing a complete valid date jumps the calendar to it, and tapping a
/// day rewrites the field text in `MM/DD/YYYY` form. Falls back to the
/// last valid selection on OK if the field is partially typed.
class _KycDateInputDialog extends StatefulWidget {
  const _KycDateInputDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_KycDateInputDialog> createState() => _KycDateInputDialogState();
}

class _KycDateInputDialogState extends State<_KycDateInputDialog> {
  late final TextEditingController _controller;
  late DateTime _selectedDate;
  String? _errorText;
  Key _calendarKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _controller = TextEditingController(text: _formatDate(_selectedDate));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.year}';

  DateTime? _parseDate(String text) {
    final parts = text.split('/');
    if (parts.length != 3) return null;
    if (parts[2].length != 4) return null;
    final m = int.tryParse(parts[0]);
    final d = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (m == null || d == null || y == null) return null;
    if (m < 1 || m > 12 || d < 1 || d > 31) return null;
    final dt = DateTime(y, m, d);
    // Reject impossible dates (e.g. Feb 30 → Mar 2 rollover).
    if (dt.year != y || dt.month != m || dt.day != d) return null;
    if (dt.isBefore(widget.firstDate) || dt.isAfter(widget.lastDate)) {
      return null;
    }
    return dt;
  }

  void _onTextChanged(String value) {
    final parsed = _parseDate(value);
    setState(() {
      if (parsed != null) {
        _selectedDate = parsed;
        _calendarKey = ValueKey(parsed);
        _errorText = null;
      } else {
        // Don't flash the error while the user is mid-typing.
        final digitCount = value.replaceAll(RegExp(r'[^0-9]'), '').length;
        _errorText = digitCount >= 8
            ? MaterialLocalizations.of(context).invalidDateFormatLabel
            : null;
      }
    });
  }

  void _onCalendarDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
      final formatted = _formatDate(date);
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      _errorText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ml = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(ml.datePickerHelpText),
      titleTextStyle: theme.textTheme.titleLarge?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: const [_DateInputFormatter()],
                onChanged: _onTextChanged,
                decoration: InputDecoration(
                  labelText: ml.dateInputLabel,
                  hintText: 'MM/DD/YYYY',
                  errorText: _errorText,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 320,
                child: CalendarDatePicker(
                  key: _calendarKey,
                  initialDate: _selectedDate,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  onDateChanged: _onCalendarDateChanged,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(ml.cancelButtonLabel),
        ),
        TextButton(
          onPressed: _errorText != null
              ? null
              : () => Navigator.of(context).pop(_selectedDate),
          child: Text(ml.okButtonLabel),
        ),
      ],
    );
  }
}
