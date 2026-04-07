# Change Phone Number Pre-Checks Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add email verification and KYC gates before the existing Change Phone Number flow, handling Scenario A (no email) and Scenario B (has email, not KYC verified).

**Architecture:** A gate provider checks email and KYC status when the user taps "Change Phone Number" in settings. Based on the result, the user is routed to: (A) Enter Email → Verify Email OTP → KYC → Change Phone Intro, or (B) KYC → Change Phone Intro. New screens reuse existing shared widgets (`ChangeDetailEnterNewView`, `OtpVerificationView`). The KYC flow is reused as-is with a new entry source `changePhone` that navigates to the Change Phone Intro on completion.

**Tech Stack:** Flutter, Provider, GoRouter, Freezed, reactive_forms, Dio (via ApiHelper)

---

### Task 1: Add Mocked API Endpoints and Service

**Files:**
- Modify: `lib/core/constants/endpoints.dart`
- Create: `lib/modules/settings/services/change_phone_email_service.dart`

- [ ] **Step 1: Add endpoint constants**

In `lib/core/constants/endpoints.dart`, add these two new getters after the existing `changePhoneVerify` getter (around line 40):

```dart
  /// Settings → change phone pre-check: send OTP to user's email, then verify.
  static String get changePhoneEmailRequest =>
      '$apiVersion/user/settings/change-phone/email/request';
  static String get changePhoneEmailVerify =>
      '$apiVersion/user/settings/change-phone/email/verify';
```

- [ ] **Step 2: Create the mocked service**

Create `lib/modules/settings/services/change_phone_email_service.dart`:

```dart
import '../../../core/constants/endpoints.dart';
import '../../../core/l10n/app_localizations_from_storage.dart';
import '../../../core/services/api_helper.dart';
import '../../../core/utils/app_exception.dart';

/// Authenticated APIs for the email verification step before changing phone.
/// Endpoints are mocked — replace with real calls when backend is ready.
class ChangePhoneEmailService {
  static const int _defaultOtpExpirySeconds = 60;

  /// Sends OTP to the given email. Returns countdown seconds.
  static Future<int> requestEmailOtp({required String email}) async {
    // TODO: Replace mock with real API call when endpoint is ready.
    // final response = await ApiHelper.post(
    //   Endpoints.changePhoneEmailRequest,
    //   {'email': email.trim()},
    // );
    // final data = response['data'];
    // final invalidMsg = appLocalizationsFromStoredLocale().invalidServerResponse;
    // if (data is! Map<String, dynamic>) {
    //   throw AppException(invalidMsg, messageKey: 'requestFailed');
    // }
    // final rawExpiry = data['otp_expiry_seconds'];
    // final expiry = rawExpiry is int
    //     ? rawExpiry
    //     : int.tryParse(rawExpiry?.toString() ?? '') ?? _defaultOtpExpirySeconds;
    // return expiry > 0 ? expiry : _defaultOtpExpirySeconds;

    await Future.delayed(const Duration(seconds: 1));
    return _defaultOtpExpirySeconds;
  }

  /// Verifies the OTP sent to the email. Throws on failure.
  static Future<void> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    // TODO: Replace mock with real API call when endpoint is ready.
    // await ApiHelper.post(Endpoints.changePhoneEmailVerify, {
    //   'email': email.trim(),
    //   'otp': otp.trim(),
    // });

    await Future.delayed(const Duration(seconds: 1));
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/core/constants/endpoints.dart lib/modules/settings/services/change_phone_email_service.dart
git commit -m "feat: add mocked endpoints and service for change-phone email verification"
```

---

### Task 2: Add KYC Entry Source for Change Phone

**Files:**
- Modify: `lib/modules/kyc_verification/utils/kyc_verification_entry_source.dart`

- [ ] **Step 1: Add `changePhone` to the enum**

In `lib/modules/kyc_verification/utils/kyc_verification_entry_source.dart`, add `changePhone` to the enum values before `unknown`:

```dart
enum KycVerificationEntrySource {
  profile,
  send,
  receive,
  swap,
  receiveHistory,
  changePhone,
  unknown;
```

The `fromExtra` method already handles string-based lookup via `.name`, so `changePhone` will work automatically when passed as a string or enum value.

- [ ] **Step 2: Commit**

```bash
git add lib/modules/kyc_verification/utils/kyc_verification_entry_source.dart
git commit -m "feat: add changePhone entry source for KYC verification"
```

---

### Task 3: Add Localization Strings

**Files:**
- Modify: `assets/l10n/app_en.arb`
- Modify: `assets/l10n/app_ar.arb`

- [ ] **Step 1: Add English strings**

Add the following keys to `assets/l10n/app_en.arb` (before the closing `}`):

```json
    "changePhoneEnterEmailTitle": "Enter your email",
    "changePhoneEnterEmailSubtitle": "Please enter your email address to receive a verification code",
    "changePhoneEnterEmailHint": "Enter email address",
    "changePhoneVerifyEmailTitle": "Verify your email",
    "changePhoneVerifyEmailSubtitle": "Enter the verification code sent to {email}",
    "@changePhoneVerifyEmailSubtitle": {
        "placeholders": {
            "email": {
                "type": "String"
            }
        }
    }
```

- [ ] **Step 2: Add Arabic strings**

Add the matching keys to `assets/l10n/app_ar.arb` (before the closing `}`):

```json
    "changePhoneEnterEmailTitle": "أدخل بريدك الإلكتروني",
    "changePhoneEnterEmailSubtitle": "يرجى إدخال عنوان بريدك الإلكتروني لتلقي رمز التحقق",
    "changePhoneEnterEmailHint": "أدخل عنوان البريد الإلكتروني",
    "changePhoneVerifyEmailTitle": "تحقق من بريدك الإلكتروني",
    "changePhoneVerifyEmailSubtitle": "أدخل رمز التحقق المرسل إلى {email}",
    "@changePhoneVerifyEmailSubtitle": {
        "placeholders": {
            "email": {
                "type": "String"
            }
        }
    }
```

- [ ] **Step 3: Generate localization code**

Run: `./scripts/gen_l10n.sh`

Expected: Localization files regenerated successfully. The new keys should be available via `context.l10n!.changePhoneEnterEmailTitle` etc.

- [ ] **Step 4: Commit**

```bash
git add assets/l10n/app_en.arb assets/l10n/app_ar.arb lib/core/l10n/
git commit -m "feat: add localization strings for change-phone email verification screens"
```

---

### Task 4: Create Email Form Provider

**Files:**
- Create: `lib/modules/settings/providers/change_phone_email_form_provider.dart`

- [ ] **Step 1: Create the provider**

Create `lib/modules/settings/providers/change_phone_email_form_provider.dart`:

```dart
import 'package:flutter/foundation.dart';

enum ChangePhoneEmailValidationError { empty, invalid }

class ChangePhoneEmailFormProvider extends ChangeNotifier {
  String _email = '';
  bool _submitted = false;
  bool _isLoading = false;

  String get email => _email;
  bool get isSubmitted => _submitted;
  bool get isLoading => _isLoading;
  String get normalizedEmail => _email.trim().toLowerCase();

  bool get isValidEmail {
    return RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    ).hasMatch(normalizedEmail);
  }

  bool get canContinue => validationError == null;

  ChangePhoneEmailValidationError? get validationError {
    if (!_submitted) return null;
    if (normalizedEmail.isEmpty) {
      return ChangePhoneEmailValidationError.empty;
    }
    if (!isValidEmail) {
      return ChangePhoneEmailValidationError.invalid;
    }
    return null;
  }

  void onEmailChanged(String value) {
    if (_email == value) return;
    _email = value;
    notifyListeners();
  }

  void markSubmitted() {
    _submitted = true;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/modules/settings/providers/change_phone_email_form_provider.dart
git commit -m "feat: add ChangePhoneEmailFormProvider for email entry screen"
```

---

### Task 5: Create Email OTP Provider

**Files:**
- Create: `lib/modules/settings/providers/change_phone_email_otp_provider.dart`

- [ ] **Step 1: Create the provider**

Create `lib/modules/settings/providers/change_phone_email_otp_provider.dart`:

```dart
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/utils/app_exception.dart';
import '../services/change_phone_email_service.dart';

class ChangePhoneEmailOtpProvider extends ChangeNotifier {
  ChangePhoneEmailOtpProvider({required String email})
      : _email = email.trim() {
    if (_email.isEmpty) {
      throw ArgumentError.value(email, 'email', 'must not be empty');
    }
  }

  static const int otpLength = 6;
  static const int countdownStartSeconds = 60;

  final String _email;

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
  bool get isComplete => _otp.length == otpLength;

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
      final expiry =
          await ChangePhoneEmailService.requestEmailOtp(email: _email);
      _countdownSeconds = expiry > 0 ? expiry : countdownStartSeconds;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    } finally {
      _isRequestingOtp = false;
      notifyListeners();
    }
  }

  Future<void> resendOtp() async {
    if (!canResend) return;
    _isRequestingOtp = true;
    notifyListeners();
    try {
      final expiry =
          await ChangePhoneEmailService.requestEmailOtp(email: _email);
      _countdownSeconds = expiry > 0 ? expiry : countdownStartSeconds;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    } finally {
      _isRequestingOtp = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp() async {
    if (!isComplete || _isVerifying) return false;
    _isVerifying = true;
    _hasError = false;
    notifyListeners();
    try {
      await ChangePhoneEmailService.verifyEmailOtp(
        email: _email,
        otp: _otp,
      );
      _hasError = false;
      return true;
    } on AppException {
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
git add lib/modules/settings/providers/change_phone_email_otp_provider.dart
git commit -m "feat: add ChangePhoneEmailOtpProvider for email OTP verification"
```

---

### Task 6: Create Enter Email Screen

**Files:**
- Create: `lib/modules/settings/view/change_phone_number/change_phone_enter_email_view.dart`

- [ ] **Step 1: Create the view**

Create `lib/modules/settings/view/change_phone_number/change_phone_enter_email_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../routes/app_router.dart';
import '../../../../widgets/common_text_field.dart';
import '../../providers/change_phone_email_form_provider.dart';
import '../../services/change_phone_email_service.dart';
import '../widgets/change_detail_enter_new_view.dart';

class ChangePhoneEnterEmailView extends StatelessWidget {
  const ChangePhoneEnterEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChangePhoneEmailFormProvider>();
    final l10n = context.l10n!;
    final theme = context.theme;
    return ChangeDetailEnterNewView(
      appBarTitle: l10n.changePhoneNumber,
      title: l10n.changePhoneEnterEmailTitle,
      subtitle: l10n.changePhoneEnterEmailSubtitle,
      isContinueLoading: provider.isLoading,
      inputField: CommonTextField(
        fillColor: Colors.transparent,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        onChanged: provider.onEmailChanged,
        hintText: l10n.changePhoneEnterEmailHint,
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
      validationErrorText: _errorText(provider.validationError, l10n),
      continueLabel: l10n.continueButton,
      onContinue: () => _onContinue(context, provider),
    );
  }

  String? _errorText(
    ChangePhoneEmailValidationError? error,
    dynamic l10n,
  ) {
    switch (error) {
      case ChangePhoneEmailValidationError.empty:
        return l10n.pleaseEnterYourEmail;
      case ChangePhoneEmailValidationError.invalid:
        return l10n.pleaseEnterAValidEmail;
      case null:
        return null;
    }
  }

  Future<void> _onContinue(
    BuildContext context,
    ChangePhoneEmailFormProvider provider,
  ) async {
    provider.markSubmitted();
    if (!provider.canContinue) return;

    provider.setLoading(true);
    try {
      await ChangePhoneEmailService.requestEmailOtp(
        email: provider.normalizedEmail,
      );
      if (!context.mounted) return;
      context.push(
        Routes.changePhoneVerifyEmailOtp,
        extra: {'email': provider.normalizedEmail},
      );
    } on AppException catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(context, e.message);
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(context, e.toString());
      }
    } finally {
      provider.setLoading(false);
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/modules/settings/view/change_phone_number/change_phone_enter_email_view.dart
git commit -m "feat: add ChangePhoneEnterEmailView screen"
```

---

### Task 7: Create Verify Email OTP Screen

**Files:**
- Create: `lib/modules/settings/view/change_phone_number/change_phone_verify_email_otp_view.dart`

- [ ] **Step 1: Create the view**

Create `lib/modules/settings/view/change_phone_number/change_phone_verify_email_otp_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../routes/app_router.dart';
import '../../../../modules/settings/services/wallet_address_service.dart';
import '../../../../widgets/otp_verification_view.dart';
import '../../../../modules/kyc_verification/utils/kyc_verification_entry_source.dart';
import '../../providers/change_phone_email_otp_provider.dart';

class ChangePhoneVerifyEmailOtpView extends StatelessWidget {
  const ChangePhoneVerifyEmailOtpView({
    super.key,
    required this.email,
  });

  final String email;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChangePhoneEmailOtpProvider>();
    final l10n = context.l10n!;
    final theme = context.theme;
    return OtpVerificationView(
      appBarTitle: l10n.changePhoneNumber,
      title: l10n.changePhoneVerifyEmailTitle,
      subtitle: l10n.changePhoneVerifyEmailSubtitle(email),
      otpLength: ChangePhoneEmailOtpProvider.otpLength,
      countdownSeconds: provider.countdownSeconds,
      canResend: provider.canResend,
      hasError: provider.hasError,
      onInitialRequest: provider.requestOtp,
      onOtpChanged: provider.setOtp,
      onOtpCompleted: () => _verify(context, provider),
      onResend: () => _resend(context, provider),
      bottomSection: Text(
        l10n.needHelpContactSupport,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Future<void> _verify(
    BuildContext context,
    ChangePhoneEmailOtpProvider provider,
  ) async {
    try {
      final valid = await provider.verifyOtp();
      if (!context.mounted) return;
      if (!valid) return;

      // Save the email for the user
      final user = context.read<AuthProvider>().state.user!;
      await WalletAddressService.saveUserEmail(user, email);

      if (!context.mounted) return;

      // Now navigate to KYC verification
      context.go(
        Routes.kycVerification,
        extra: KycVerificationEntrySource.changePhone,
      );
    } on AppException catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(context, e.message);
      }
    }
  }

  Future<void> _resend(
    BuildContext context,
    ChangePhoneEmailOtpProvider provider,
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
git add lib/modules/settings/view/change_phone_number/change_phone_verify_email_otp_view.dart
git commit -m "feat: add ChangePhoneVerifyEmailOtpView screen"
```

---

### Task 8: Add Routes and Update KYC Navigation

**Files:**
- Modify: `lib/routes/app_routes.dart`
- Modify: `lib/routes/app_router.dart`
- Modify: `lib/modules/kyc_verification/view/kyc_verification_view.dart`

- [ ] **Step 1: Add route constants in `app_routes.dart`**

In the `Routes` class (around line 18), add after `changePhoneIntro`:

```dart
  static const String changePhoneEnterEmail = _Paths.changePhoneEnterEmail;
  static const String changePhoneVerifyEmailOtp =
      _Paths.changePhoneVerifyEmailOtp;
```

In the `_Paths` class (around line 67), add after `changePhoneIntro`:

```dart
  static const String changePhoneEnterEmail = '/change-phone-enter-email';
  static const String changePhoneVerifyEmailOtp =
      '/change-phone-verify-email-otp';
```

- [ ] **Step 2: Add route entries in `app_router.dart`**

Add these imports at the top of `app_router.dart`:

```dart
import '../modules/settings/view/change_phone_number/change_phone_enter_email_view.dart';
import '../modules/settings/view/change_phone_number/change_phone_verify_email_otp_view.dart';
import '../modules/settings/providers/change_phone_email_form_provider.dart';
import '../modules/settings/providers/change_phone_email_otp_provider.dart';
```

Add these two route entries right before the existing `changePhoneIntro` route (before the `GoRoute` at line ~343):

```dart
      GoRoute(
        path: Routes.changePhoneEnterEmail,
        name: 'changePhoneEnterEmail',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => ChangePhoneEmailFormProvider(),
          child: const ChangePhoneEnterEmailView(),
        ),
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.changePhoneVerifyEmailOtp,
        name: 'changePhoneVerifyEmailOtp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra?['email'] as String? ?? '';
          return ChangeNotifierProvider(
            create: (_) => ChangePhoneEmailOtpProvider(email: email),
            child: ChangePhoneVerifyEmailOtpView(email: email),
          );
        },
        redirect: AuthMiddleware.isAuthenticated,
      ),
```

- [ ] **Step 3: Update KYC view to handle `changePhone` entry source**

In `lib/modules/kyc_verification/view/kyc_verification_view.dart`, the submit button's `onPressed` handler currently calls `context.pop()` when `result.shouldNavigateBack` is true (around line 159). Update that block to navigate to the Change Phone Intro when the entry source is `changePhone`:

Replace the block starting at line 152 (inside the `onPressed` callback):

```dart
                                  if (!context.mounted) return;
                                  if (result.message.isNotEmpty) {
                                    SnackbarHelper.showSuccess(
                                      context,
                                      result.message,
                                    );
                                  }
                                  if (result.shouldNavigateBack) {
                                    context.pop();
                                  }
```

With:

```dart
                                  if (!context.mounted) return;
                                  if (result.message.isNotEmpty) {
                                    SnackbarHelper.showSuccess(
                                      context,
                                      result.message,
                                    );
                                  }
                                  if (result.shouldNavigateBack) {
                                    if (entrySource ==
                                        KycVerificationEntrySource
                                            .changePhone) {
                                      context.go(Routes.changePhoneIntro);
                                    } else {
                                      context.pop();
                                    }
                                  }
```

You will also need to add this import at the top of the file if not already present:

```dart
import '../../../routes/app_router.dart';
```

(Check: this import is already present at line 7 via `go_router` — but `Routes` comes from `app_router.dart`. Verify and add if needed.)

- [ ] **Step 4: Commit**

```bash
git add lib/routes/app_routes.dart lib/routes/app_router.dart lib/modules/kyc_verification/view/kyc_verification_view.dart
git commit -m "feat: add routes for change-phone email screens and update KYC post-navigation"
```

---

### Task 9: Update Settings View Gate Logic

**Files:**
- Modify: `lib/modules/settings/view/settings_view.dart`

- [ ] **Step 1: Update the "Change Phone Number" onTap handler**

In `lib/modules/settings/view/settings_view.dart`, the current onTap for "Change Phone Number" (around line 76-78) is:

```dart
                        onTap: () {
                          GoRouter.of(context).push(Routes.changePhoneIntro);
                        },
```

Replace it with gate logic that checks email and KYC status:

```dart
                        onTap: () {
                          final user = authProvider.state.user;
                          if (user == null) return;
                          final hasEmail = WalletAddressService.getUserEmail(
                            user,
                          ).isNotEmpty;
                          final isKycVerified = user.isVerified;

                          if (!hasEmail) {
                            GoRouter.of(context).push(
                              Routes.changePhoneEnterEmail,
                            );
                          } else if (!isKycVerified) {
                            GoRouter.of(context).push(
                              Routes.kycVerification,
                              extra: KycVerificationEntrySource.changePhone,
                            );
                          } else {
                            GoRouter.of(context).push(
                              Routes.changePhoneIntro,
                            );
                          }
                        },
```

- [ ] **Step 2: Add required imports**

Add these imports at the top of `settings_view.dart`:

```dart
import '../../../modules/kyc_verification/utils/kyc_verification_entry_source.dart';
import '../services/wallet_address_service.dart';
```

- [ ] **Step 3: Commit**

```bash
git add lib/modules/settings/view/settings_view.dart
git commit -m "feat: add email and KYC gate logic to Change Phone Number in settings"
```

---

### Task 10: Verify the Complete Flow

- [ ] **Step 1: Run code generation**

Run: `./scripts/gen_l10n.sh`

Expected: Localization files generated without errors.

- [ ] **Step 2: Run static analysis**

Run: `flutter analyze`

Expected: No new errors or warnings introduced by our changes.

- [ ] **Step 3: Manually verify flow logic**

Verify by reading the code that:
1. Settings view checks email → routes to enter email screen if missing
2. Settings view checks KYC → routes to KYC if email exists but not verified
3. Enter email screen → validates → calls mocked API → navigates to verify OTP
4. Verify OTP screen → verifies OTP → saves email → navigates to KYC
5. KYC view with `changePhone` source → on approval → navigates to Change Phone Intro
6. All new strings are localized in both EN and AR

- [ ] **Step 4: Final commit if any fixes needed**

```bash
git add -A
git commit -m "fix: address any issues found during verification"
```
