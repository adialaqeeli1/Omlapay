# KYC Email Pre-Check Design Spec

## Summary

Before launching the SumSub KYC SDK, require the user to provide and verify an email address via OTP. Since no user currently has an email, this gate always triggers on KYC submit. APIs are mocked for now.

## Flow

```
KYC Form (tap submit)
  → push /kyc-email-entry
    → user enters email, taps continue
    → mock API: send OTP to email
    → push /kyc-email-verify-otp
      → user enters 6-digit OTP
      → mock API: verify OTP (hardcoded "123456")
      → on success: pop both email routes back to KYC form
      → auto-trigger SumSub SDK launch
        → on SumSub Approved: call Binance KYC API
        → context.go() to source route (home/profile/send/receive/swap)
```

## Navigation

- Email entry and OTP are pushed as separate GoRouter routes
- After OTP verification succeeds, pop back to KYC form and auto-launch SumSub
- After SumSub completes (Approved/FinallyRejected/Failed) + Binance KYC (on Approved), use `context.go()` to navigate to the source page route based on `KycVerificationEntrySource`:
  - `profile` → `Routes.profile`
  - `send` → `Routes.home`
  - `receive` → `Routes.home`
  - `swap` → `Routes.home`
  - `receiveHistory` → `Routes.home`
  - `unknown` → `Routes.home`

## New Files

All within `lib/modules/kyc_verification/`:

| File | Purpose |
|------|---------|
| `services/kyc_email_service.dart` | Mock API: `sendOtp(email)` and `verifyOtp(email, otp)` using `Future.delayed` |
| `providers/kyc_email_provider.dart` | Manages email input validation, OTP state (input, countdown, resend, error), calls mock service |
| `views/kyc_email_entry_view.dart` | Email input page — text field, validation, continue button |
| `views/kyc_email_otp_view.dart` | OTP verification page — reuses shared `OtpVerificationView` widget from `lib/widgets/` |

## Modified Files

| File | Change |
|------|--------|
| `lib/routes/app_routes.dart` | Add `kycEmailEntry` and `kycEmailVerifyOtp` route constants |
| `lib/routes/app_router.dart` | Add route definitions for the two new pages |
| `lib/modules/kyc_verification/providers/kyc_verification_provider.dart` | Change `submit()` to first push email entry route instead of directly launching SumSub. Add method to launch SumSub after email is verified. Use `context.go()` to source route on completion instead of `context.pop()`. |
| `lib/modules/kyc_verification/view/kyc_verification_view.dart` | Pass `entrySource` and navigation context so the provider can `context.go()` back to source |
| `assets/l10n/app_en.arb` | Add localization keys for email entry and OTP screens |
| `assets/l10n/app_ar.arb` | Add matching Arabic translations |

## Mock API Details

### `KycEmailService.sendOtp(String email)`
- `Future.delayed(Duration(milliseconds: 500))`
- Returns `{'status': 'success', 'message': 'OTP sent'}`
- Always succeeds

### `KycEmailService.verifyOtp(String email, String otp)`
- `Future.delayed(Duration(milliseconds: 500))`
- Hardcoded valid OTP: `"123456"`
- Returns `true` if OTP matches, throws `AppException` otherwise

## Provider: `KycEmailProvider`

Single provider managing both email entry and OTP verification steps:

- **Email state**: `email` string, validation (empty, invalid format)
- **OTP state**: `otp` string, `countdownSeconds`, `canResend`, `hasError`, `isVerifying`
- **Methods**: `setEmail()`, `validateEmail()`, `requestOtp()`, `setOtp()`, `verifyOtp()`, `resendOtp()`
- Countdown timer: starts at 30 seconds after OTP request, ticks down, enables resend at 0
- OTP length: 6 digits

## Email Entry View

- AppBar with back button, title: localized "Enter Email"
- Title text: localized "What's your email?"
- Subtitle: localized "We'll send a verification code to confirm your email"
- Email text field with validation error display
- Continue button at bottom — disabled until email is valid, shows loading spinner during API call
- On continue: calls `provider.requestOtp()` then pushes OTP route

## OTP View

- Reuses `OtpVerificationView` widget from `lib/widgets/otp_verification_view.dart`
- Passes: title, subtitle (mentioning the email), OTP length (6), countdown, handlers
- On OTP completed + verified: pops both email routes, returns to KYC form with a result indicating email is verified
- KYC form then auto-launches SumSub

## Return Flow After SumSub

The `KycVerificationProvider.submit()` method currently does `context.pop()`. This changes to `context.go()` targeting the source route. The `entrySource` enum maps to:

```dart
String _sourceRoute(KycVerificationEntrySource source) {
  switch (source) {
    case KycVerificationEntrySource.profile:
      return Routes.profile;
    default:
      return Routes.home;
  }
}
```

## Localization Keys (new)

- `kycEnterEmail` — "Enter Email"
- `kycWhatsYourEmail` — "What's your email?"
- `kycEmailSubtitle` — "We'll send a verification code to confirm your email"
- `kycEmailHint` — "Enter your email address"
- `kycEmailRequiredError` — "Email address is required"
- `kycEmailInvalidError` — "Please enter a valid email address"
- `kycVerifyEmail` — "Verify Email"
- `kycVerifyEmailTitle` — "Enter verification code"
- `kycVerifyEmailSubtitle` — "We sent a 6-digit code to {email}"
- `kycEmailVerified` — "Email verified successfully"
