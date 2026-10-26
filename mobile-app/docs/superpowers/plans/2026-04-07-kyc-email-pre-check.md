# KYC Email Pre-Check Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Gate the KYC SumSub flow behind email collection + OTP verification, with mocked APIs.

**Architecture:** New email entry and OTP screens within `lib/modules/kyc_verification/`, registered as GoRouter routes. A single `KycEmailProvider` manages email input, OTP state, and mock API calls. After OTP verification, control returns to the existing KYC form which auto-launches SumSub. On SumSub completion, `context.go()` navigates back to the source page.

**Tech Stack:** Flutter, Provider, GoRouter, `OtpVerificationView` (shared widget), `CommonTextField` (shared widget)

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `lib/modules/kyc_verification/services/kyc_email_service.dart` | Create | Mock send OTP / verify OTP APIs |
| `lib/modules/kyc_verification/providers/kyc_email_provider.dart` | Create | Email validation, OTP state, countdown timer, calls mock service |
| `lib/modules/kyc_verification/views/kyc_email_entry_view.dart` | Create | Email input page |
| `lib/modules/kyc_verification/views/kyc_email_otp_view.dart` | Create | OTP verification page using shared `OtpVerificationView` |
| `lib/modules/kyc_verification/providers/kyc_verification_provider.dart` | Modify | Refactor `submit()` to push email route first; add `launchSumSub()` for post-email flow; use `context.go()` for final navigation |
| `lib/modules/kyc_verification/view/kyc_verification_view.dart` | Modify | Handle return from email flow, auto-launch SumSub |
| `lib/routes/app_routes.dart` | Modify | Add `kycEmailEntry` and `kycEmailVerifyOtp` route constants |
| `lib/routes/app_router.dart` | Modify | Add GoRoute definitions for the two new pages |
| `assets/l10n/app_en.arb` | Modify | Add new localization keys |
| `assets/l10n/app_ar.arb` | Modify | Add matching Arabic keys |

---

### Task 1: Add Localization Keys

**Files:**
- Modify: `assets/l10n/app_en.arb`
- Modify: `assets/l10n/app_ar.arb`

- [ ] **Step 1: Add English localization keys**

Add these entries to `assets/l10n/app_en.arb` (before the closing `}`):

```json
    "kycEnterEmail": "Enter Email",
    "kycWhatsYourEmail": "What's your email?",
    "kycEmailSubtitle": "We'll send a verification code to confirm your email",
    "kycEmailHint": "Enter your email address",
    "kycEmailRequiredError": "Email address is required",
    "kycEmailInvalidError": "Please enter a valid email address",
    "kycVerifyEmail": "Verify Email",
    "kycVerifyEmailTitle": "Enter verification code",
    "kycVerifyEmailSubtitle": "We sent a 6-digit code to {email}",
    "@kycVerifyEmailSubtitle": {
        "placeholders": {
            "email": {
                "type": "String"
            }
        }
    },
    "kycEmailVerified": "Email verified successfully"
```

- [ ] **Step 2: Add Arabic localization keys**

Add matching entries to `assets/l10n/app_ar.arb` (before the closing `}`):

```json
    "kycEnterEmail": "أدخل البريد الإلكتروني",
    "kycWhatsYourEmail": "ما هو بريدك الإلكتروني؟",
    "kycEmailSubtitle": "سنرسل رمز تحقق لتأكيد بريدك الإلكتروني",
    "kycEmailHint": "أدخل عنوان بريدك الإلكتروني",
    "kycEmailRequiredError": "عنوان البريد الإلكتروني مطلوب",
    "kycEmailInvalidError": "يرجى إدخال عنوان بريد إلكتروني صالح",
    "kycVerifyEmail": "تحقق من البريد الإلكتروني",
    "kycVerifyEmailTitle": "أدخل رمز التحقق",
    "kycVerifyEmailSubtitle": "لقد أرسلنا رمزًا مكونًا من 6 أرقام إلى {email}",
    "@kycVerifyEmailSubtitle": {
        "placeholders": {
            "email": {
                "type": "String"
            }
        }
    },
    "kycEmailVerified": "تم التحقق من البريد الإلكتروني بنجاح"
```

- [ ] **Step 3: Generate localization code**

Run: `./scripts/gen_l10n.sh`
Expected: Localization files regenerated without errors.

- [ ] **Step 4: Commit**

```bash
git add assets/l10n/app_en.arb assets/l10n/app_ar.arb lib/core/l10n/
git commit -m "feat(kyc): add localization keys for email pre-check flow"
```

---

### Task 2: Create Mock Email Service

**Files:**
- Create: `lib/modules/kyc_verification/services/kyc_email_service.dart`

- [ ] **Step 1: Create the mock service**

Create `lib/modules/kyc_verification/services/kyc_email_service.dart`:

```dart
import '../../../core/utils/app_exception.dart';

class KycEmailService {
  KycEmailService._();

  static const String _validOtp = '123456';

  static Future<void> sendOtp(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock: always succeeds
  }

  static Future<bool> verifyOtp(String email, String otp) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (otp == _validOtp) {
      return true;
    }
    throw AppException('Invalid OTP code');
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/modules/kyc_verification/services/kyc_email_service.dart
git commit -m "feat(kyc): add mock email OTP service"
```

---

### Task 3: Create KycEmailProvider

**Files:**
- Create: `lib/modules/kyc_verification/providers/kyc_email_provider.dart`

- [ ] **Step 1: Create the provider**

Create `lib/modules/kyc_verification/providers/kyc_email_provider.dart`:

```dart
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/extentions/string_extensions.dart';
import '../../../core/utils/app_exception.dart';
import '../services/kyc_email_service.dart';

class KycEmailProvider extends ChangeNotifier {
  static const int otpLength = 6;
  static const int countdownStartSeconds = 30;

  // -- Email state --
  String _email = '';
  bool _emailSubmitted = false;

  String get email => _email;
  bool get isEmailValid => _email.trim().isEmail;

  String? get emailError {
    if (!_emailSubmitted) return null;
    final trimmed = _email.trim();
    if (trimmed.isEmpty) return 'empty';
    if (!trimmed.isEmail) return 'invalid';
    return null;
  }

  void setEmail(String value) {
    _email = value;
    if (_emailSubmitted) notifyListeners();
  }

  void markEmailSubmitted() {
    _emailSubmitted = true;
    notifyListeners();
  }

  // -- OTP state --
  String _otp = '';
  int _countdownSeconds = 0;
  Timer? _timer;
  bool _isRequestingOtp = false;
  bool _isVerifying = false;
  bool _hasError = false;

  String get otp => _otp;
  int get countdownSeconds => _countdownSeconds;
  bool get canResend => _countdownSeconds <= 0 && !_isRequestingOtp;
  bool get isRequestingOtp => _isRequestingOtp;
  bool get isVerifying => _isVerifying;
  bool get hasError => _hasError;
  bool get isOtpComplete => _otp.length == otpLength;

  void setOtp(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    final truncated =
        digits.length > otpLength ? digits.substring(0, otpLength) : digits;
    if (_otp == truncated) return;
    _otp = truncated;
    _hasError = false;
    notifyListeners();
  }

  Future<void> requestOtp() async {
    if (_isRequestingOtp) return;
    _isRequestingOtp = true;
    notifyListeners();
    try {
      await KycEmailService.sendOtp(_email.trim());
      _countdownSeconds = countdownStartSeconds;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    } finally {
      _isRequestingOtp = false;
      notifyListeners();
    }
  }

  Future<void> resendOtp() async {
    if (!canResend) return;
    await requestOtp();
  }

  /// Returns `true` on success. Throws [AppException] on failure.
  Future<bool> verifyOtp() async {
    if (!isOtpComplete || _isVerifying) return false;
    _isVerifying = true;
    _hasError = false;
    notifyListeners();
    try {
      final result = await KycEmailService.verifyOtp(_email.trim(), _otp);
      _hasError = !result;
      return result;
    } on AppException {
      _hasError = true;
      rethrow;
    } finally {
      _isVerifying = false;
      notifyListeners();
    }
  }

  void _tick(Timer timer) {
    if (_countdownSeconds <= 1) {
      _timer?.cancel();
      _timer = null;
      _countdownSeconds = 0;
    } else {
      _countdownSeconds--;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/modules/kyc_verification/providers/kyc_email_provider.dart
git commit -m "feat(kyc): add KycEmailProvider for email and OTP state"
```

---

### Task 4: Create Email Entry View

**Files:**
- Create: `lib/modules/kyc_verification/views/kyc_email_entry_view.dart`

- [ ] **Step 1: Create the email entry view**

Create `lib/modules/kyc_verification/views/kyc_email_entry_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common_back_button.dart';
import '../../../widgets/common_text_field.dart';
import '../providers/kyc_email_provider.dart';

class KycEmailEntryView extends StatelessWidget {
  const KycEmailEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final isDark = context.isDarkMode;
    final provider = context.watch<KycEmailProvider>();

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
    final provider = context.read<KycEmailProvider>();
    provider.markEmailSubmitted();
    if (!provider.isEmailValid) return;

    try {
      await provider.requestOtp();
      if (!context.mounted) return;
      context.push(Routes.kycEmailVerifyOtp);
    } catch (e) {
      if (!context.mounted) return;
      SnackbarHelper.showError(context, e.toString());
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/modules/kyc_verification/views/kyc_email_entry_view.dart
git commit -m "feat(kyc): add email entry view for KYC pre-check"
```

---

### Task 5: Create Email OTP View

**Files:**
- Create: `lib/modules/kyc_verification/views/kyc_email_otp_view.dart`

- [ ] **Step 1: Create the OTP verification view**

Create `lib/modules/kyc_verification/views/kyc_email_otp_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/utils/app_exception.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../widgets/otp_verification_view.dart';
import '../providers/kyc_email_provider.dart';

class KycEmailOtpView extends StatelessWidget {
  const KycEmailOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final provider = context.watch<KycEmailProvider>();

    return OtpVerificationView(
      appBarTitle: l10n.kycVerifyEmail,
      title: l10n.kycVerifyEmailTitle,
      subtitle: l10n.kycVerifyEmailSubtitle(provider.email.trim()),
      otpLength: KycEmailProvider.otpLength,
      countdownSeconds: provider.countdownSeconds,
      canResend: provider.canResend,
      hasError: provider.hasError,
      onInitialRequest: () async {
        // OTP was already requested when navigating here from email entry
      },
      onOtpChanged: provider.setOtp,
      onOtpCompleted: () => _onOtpCompleted(context, provider),
      onResend: () => _onResend(context, provider),
    );
  }

  Future<void> _onOtpCompleted(
    BuildContext context,
    KycEmailProvider provider,
  ) async {
    try {
      final valid = await provider.verifyOtp();
      if (!context.mounted || !valid) return;
      // Pop OTP view and email entry view, returning true to KYC form
      context.pop(true); // pop OTP view
    } on AppException catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(context, e.message);
      }
    }
  }

  Future<void> _onResend(
    BuildContext context,
    KycEmailProvider provider,
  ) async {
    try {
      await provider.resendOtp();
    } on AppException catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(context, e.message);
      }
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/modules/kyc_verification/views/kyc_email_otp_view.dart
git commit -m "feat(kyc): add email OTP verification view for KYC pre-check"
```

---

### Task 6: Add Routes

**Files:**
- Modify: `lib/routes/app_routes.dart`
- Modify: `lib/routes/app_router.dart`

- [ ] **Step 1: Add route constants to `app_routes.dart`**

In the `Routes` class, add after the `kycVerification` line:

```dart
  static const String kycEmailEntry = _Paths.kycEmailEntry;
  static const String kycEmailVerifyOtp = _Paths.kycEmailVerifyOtp;
```

In the `_Paths` class, add after the `kycVerification` line:

```dart
  static const String kycEmailEntry = '/kyc-email-entry';
  static const String kycEmailVerifyOtp = '/kyc-email-verify-otp';
```

- [ ] **Step 2: Add route definitions to `app_router.dart`**

Add import at top of `app_router.dart`:

```dart
import '../modules/kyc_verification/providers/kyc_email_provider.dart';
import '../modules/kyc_verification/views/kyc_email_entry_view.dart';
import '../modules/kyc_verification/views/kyc_email_otp_view.dart';
```

Add GoRoute entries after the existing `kycVerification` route (around line 507). These routes share a `KycEmailProvider` — the email entry route creates it, and the OTP route reads it from the ancestor. To accomplish this, wrap both in a `ShellRoute` or pass the provider via InheritedWidget. The simplest approach: the `kycEmailEntry` route creates the provider, and pushes the OTP route which reads it from the widget tree.

However, since these are top-level GoRouter routes (not nested), the provider won't be in the tree for the OTP route. Instead, make the `kycEmailEntry` route create the provider, and when navigating to OTP, pass the provider reference via `extra`:

```dart
      GoRoute(
        path: Routes.kycEmailEntry,
        name: 'kycEmailEntry',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => KycEmailProvider(),
          child: const KycEmailEntryView(),
        ),
      ),
      GoRoute(
        path: Routes.kycEmailVerifyOtp,
        name: 'kycEmailVerifyOtp',
        builder: (context, state) {
          final provider = state.extra as KycEmailProvider;
          return ChangeNotifierProvider.value(
            value: provider,
            child: const KycEmailOtpView(),
          );
        },
      ),
```

- [ ] **Step 3: Update email entry view to pass provider via extra**

In `lib/modules/kyc_verification/views/kyc_email_entry_view.dart`, update the `_onContinue` method's push call:

Change:
```dart
      context.push(Routes.kycEmailVerifyOtp);
```

To:
```dart
      context.push(Routes.kycEmailVerifyOtp, extra: provider);
```

- [ ] **Step 4: Update OTP view pop to return result through email entry**

In `lib/modules/kyc_verification/views/kyc_email_otp_view.dart`, the `context.pop(true)` pops the OTP view back to email entry. The email entry view needs to handle this result and also pop back to KYC form with a `true` result.

Update `_onContinue` in `kyc_email_entry_view.dart`:

Change:
```dart
      context.push(Routes.kycEmailVerifyOtp, extra: provider);
```

To:
```dart
      final verified = await context.push<bool>(
        Routes.kycEmailVerifyOtp,
        extra: provider,
      );
      if (!context.mounted) return;
      if (verified == true) {
        context.pop(true); // pop email entry back to KYC form
      }
```

- [ ] **Step 5: Commit**

```bash
git add lib/routes/app_routes.dart lib/routes/app_router.dart lib/modules/kyc_verification/views/kyc_email_entry_view.dart lib/modules/kyc_verification/views/kyc_email_otp_view.dart
git commit -m "feat(kyc): add routes for email entry and OTP verification"
```

---

### Task 7: Refactor KycVerificationProvider and View

**Files:**
- Modify: `lib/modules/kyc_verification/providers/kyc_verification_provider.dart`
- Modify: `lib/modules/kyc_verification/view/kyc_verification_view.dart`

- [ ] **Step 1: Add source route helper to `KycVerificationEntrySource`**

Add a helper method to `lib/modules/kyc_verification/utils/kyc_verification_entry_source.dart`:

```dart
import '../../../routes/app_router.dart';
```

Add this method inside the enum:

```dart
  String get sourceRoute {
    switch (this) {
      case KycVerificationEntrySource.profile:
        return Routes.profile;
      default:
        return Routes.home;
    }
  }
```

- [ ] **Step 2: Refactor `KycVerificationProvider` to separate form validation from SumSub launch**

The existing `submit()` method validates the form AND launches SumSub. Split it so:
1. `validateAndCollectFormData()` — validates form, returns the form data record (or null if invalid)
2. `launchSumSub()` — takes form data, fetches KYC token, launches SumSub SDK, handles result

Replace the entire `submit` method in `lib/modules/kyc_verification/providers/kyc_verification_provider.dart`:

```dart
  /// Validates form and returns collected data, or null if invalid.
  ({
    String firstName,
    String lastName,
    String residentialCountry,
    String documentCountry,
    String city,
    String address,
    String dob,
  })? validateForm(FormGroup form) {
    form.markAllAsTouched();
    if (!form.valid) return null;

    final firstName =
        (form.control('firstName').value ?? '').toString().trim();
    final lastName =
        (form.control('lastName').value ?? '').toString().trim();
    final residentialCountry =
        (form.control('residentialCountry').value ?? '')
            .toString()
            .trim()
            .toUpperCase();
    final documentCountry =
        (form.control('documentCountry').value ?? '')
            .toString()
            .trim()
            .toUpperCase();
    final city = (form.control('city').value ?? '').toString().trim();
    final address = (form.control('address').value ?? '').toString().trim();
    final dob = _toIsoDate(
      (form.control('dateOfBirth').value ?? '').toString(),
    );

    return (
      firstName: firstName,
      lastName: lastName,
      residentialCountry: residentialCountry,
      documentCountry: documentCountry,
      city: city,
      address: address,
      dob: dob,
    );
  }

  Future<({String message, bool shouldNavigateBack})> launchSumSub({
    required String firstName,
    required String lastName,
    required String residentialCountry,
    required String documentCountry,
    required String city,
    required String address,
    required String dob,
    required Locale locale,
    required String startFailedFallback,
    required String successFallback,
    required AuthProvider authProvider,
  }) async {
    if (_isSubmitting) {
      return (message: '', shouldNavigateBack: false);
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final requestPayload = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'residentialCountry': residentialCountry,
        'dob': dob,
        'country': documentCountry,
        'city': city,
        'address': address,
      };

      debugPrint(
        'KycVerificationProvider.launchSumSub request: ${jsonEncode(requestPayload)}',
      );

      final response = await _fetchKycAccessToken(
        firstName: firstName,
        lastName: lastName,
        residentialCountry: residentialCountry,
        dob: dob,
        country: documentCountry,
        city: city,
        address: address,
      );

      final accessToken = response.token;

      if (accessToken.isEmpty) {
        throw Exception(
          ApiMessageHelper.localizedFromResponse(
            response.raw,
            fallback: startFailedFallback,
          ),
        );
      }

      Future<String> onTokenExpiration() async {
        debugPrint('KYC token expired - fetching new access token');
        final refreshed = await _fetchKycAccessToken(
          firstName: firstName,
          lastName: lastName,
          residentialCountry: residentialCountry,
          dob: dob,
          country: documentCountry,
          city: city,
          address: address,
        );
        return refreshed.token;
      }

      void onStatusChanged(
        SNSMobileSDKStatus newStatus,
        SNSMobileSDKStatus prevStatus,
      ) {
        debugPrint('Sumsub status changed: $prevStatus -> $newStatus');
      }

      void onEvent(SNSMobileSDKEvent event) {
        debugPrint('Sumsub event: $event');
      }

      final sdk = SNSMobileSDK.init(accessToken, onTokenExpiration)
          .withHandlers(onStatusChanged: onStatusChanged, onEvent: onEvent)
          .withDebug(kDebugMode)
          .withLocale(locale)
          .build();

      final result = await sdk.launch();
      debugPrint('Sumsub SDK completed with result: $result');

      final shouldBack =
          result.status == SNSMobileSDKStatus.Approved ||
          result.status == SNSMobileSDKStatus.FinallyRejected ||
          result.status == SNSMobileSDKStatus.Failed;

      if (result.status == SNSMobileSDKStatus.Approved) {
        try {
          debugPrint('Sumsub approved — starting Binance KYC');
          await KycVerificationService.startBinanceKyc();
          debugPrint('Binance KYC started — refreshing account details');
          await authProvider.fetchAccountDetails();
        } catch (e) {
          debugPrint('Post-approval flow error: $e');
        }
      }

      final message = ApiMessageHelper.localizedFromResponse(
        response.raw,
        fallback: successFallback,
      );

      return (message: message, shouldNavigateBack: shouldBack);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
```

Remove the old `submit()` method entirely.

- [ ] **Step 3: Refactor KYC form view to push email route on submit, auto-launch SumSub on return**

In `lib/modules/kyc_verification/view/kyc_verification_view.dart`:

Add imports at top:

```dart
import '../../../routes/app_router.dart';
import '../utils/kyc_verification_entry_source.dart';
```

Note: `entrySource` is already available. The `KycVerificationView` already receives it.

Replace the `onPressed` callback of the `FilledButton` (the `form.valid ? () async { ... } : null` block). The new logic:
1. Validate the form
2. Push email entry route
3. On return with `true`, auto-launch SumSub
4. On SumSub completion, `context.go()` to source route

Replace the entire `onPressed` closure:

```dart
                        onPressed: form.valid
                            ? () async {
                                FocusScope.of(context).unfocus();
                                final kycProvider =
                                    context.read<KycVerificationProvider>();
                                final formData =
                                    kycProvider.validateForm(_form);
                                if (formData == null) return;

                                // Push email entry; wait for verified result
                                final emailVerified =
                                    await context.push<bool>(
                                  Routes.kycEmailEntry,
                                );
                                if (!context.mounted ||
                                    emailVerified != true) {
                                  return;
                                }

                                // Email verified — launch SumSub
                                try {
                                  final result =
                                      await kycProvider.launchSumSub(
                                    firstName: formData.firstName,
                                    lastName: formData.lastName,
                                    residentialCountry:
                                        formData.residentialCountry,
                                    documentCountry:
                                        formData.documentCountry,
                                    city: formData.city,
                                    address: formData.address,
                                    dob: formData.dob,
                                    locale:
                                        Localizations.localeOf(context),
                                    startFailedFallback:
                                        l10n.requestFailed,
                                    successFallback:
                                        l10n.kycStartedSuccess,
                                    authProvider:
                                        context.read<AuthProvider>(),
                                  );
                                  if (!context.mounted) return;
                                  if (result.message.isNotEmpty) {
                                    SnackbarHelper.showSuccess(
                                      context,
                                      result.message,
                                    );
                                  }
                                  if (result.shouldNavigateBack) {
                                    context.go(
                                      entrySource.sourceRoute,
                                    );
                                  }
                                } catch (e) {
                                  if (!context.mounted) return;
                                  SnackbarHelper.showError(
                                    context,
                                    e.toString(),
                                  );
                                }
                              }
                            : null,
```

- [ ] **Step 4: Commit**

```bash
git add lib/modules/kyc_verification/utils/kyc_verification_entry_source.dart lib/modules/kyc_verification/providers/kyc_verification_provider.dart lib/modules/kyc_verification/view/kyc_verification_view.dart
git commit -m "feat(kyc): gate SumSub behind email verification with context.go navigation"
```

---

### Task 8: Verify and Fix Compilation

**Files:**
- Possibly all modified files

- [ ] **Step 1: Run flutter analyze**

Run: `flutter analyze`
Expected: No errors (warnings acceptable).

- [ ] **Step 2: Fix any compilation errors**

Address any import issues, missing references, or type mismatches found by the analyzer.

- [ ] **Step 3: Commit fixes if any**

```bash
git add -u
git commit -m "fix(kyc): resolve compilation issues in email pre-check flow"
```

---

### Task 9: Manual Smoke Test Checklist

- [ ] **Step 1: Verify the full flow**

Run the app: `./scripts/run.sh`

Test sequence:
1. Navigate to KYC verification (from profile or banner)
2. Fill in all KYC form fields
3. Tap Submit — should navigate to email entry page
4. Enter an invalid email → should show validation error
5. Enter a valid email, tap Continue → should show loading, then navigate to OTP page
6. Enter wrong OTP (e.g. `000000`) → should show error
7. Enter `123456` → should verify, pop back through email entry to KYC form
8. SumSub SDK should auto-launch
9. After SumSub completes → should `context.go()` back to the source page (home or profile)

- [ ] **Step 2: Test back navigation**

1. From email entry, press back → should return to KYC form (SumSub should NOT launch)
2. From OTP page, press back → should return to email entry
