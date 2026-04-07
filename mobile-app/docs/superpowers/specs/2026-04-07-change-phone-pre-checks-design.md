# Change Phone Number Pre-Checks Design

## Summary

Add email and KYC verification gates before the existing Change Phone Number flow. When a user taps "Change Phone Number" in settings, the app checks two conditions — (1) does the user have an email, and (2) is the user KYC verified. If either condition is unmet, the user is guided through the required steps before auto-navigating to the existing Change Phone intro.

## Scenarios

### Scenario A — No email, not KYC verified

1. Enter Email page — user provides their email address
2. Verify Email OTP page — user confirms the OTP sent to that email
3. KYC Form + SumSub flow — existing KYC verification (form fields then SumSub SDK)
4. Auto-navigate to Change Phone Intro (existing flow continues from here)

### Scenario B — Has email, not KYC verified

1. KYC Form + SumSub flow — existing KYC verification
2. Auto-navigate to Change Phone Intro (existing flow continues from here)

## Flow Diagram

```
User taps "Change Phone"
        |
        v
   Has email? ---- NO ----> Enter Email Page
        |                        |
       YES                       v
        |               Verify Email OTP Page
        |                        |
        v                        v
  Is KYC verified? <-------------+
        |
       NO ----> KYC Form -> SumSub Flow
        |                    |
       YES                   |
        |                    v
        v<-------------------+
  Change Phone Intro (existing flow)
```

## Gate Logic

A `ChangePhoneGateProvider` determines which screen to route to when the user taps "Change Phone Number":

- Reads `email` from `WalletAddressService.getUserEmail(user)` (or equivalent)
- Reads `isVerified` from `AuthProvider.user.isVerified`
- Routes accordingly:
  - No email -> `/change-phone-enter-email`
  - Has email, not KYC verified -> `/kyc-verification` (existing route, with source context indicating it came from change-phone)
  - Both satisfied -> `/change-phone-intro` (existing)

After email verification completes, the gate re-evaluates and routes to KYC.
After KYC completes, the gate auto-navigates to `/change-phone-intro`.

## New Screens

### Enter Email Page (`/change-phone-enter-email`)

- **Purpose:** Collect the user's email address before phone change
- **UI:** Reuses the `ChangeDetailEnterNewView` pattern (app bar, title, subtitle, single input field, continue button)
- **Input:** Email text field with validation (empty, invalid format, using existing email regex pattern from `ChangeEmailFormProvider`)
- **On submit:** Calls mocked API endpoint to send OTP to the entered email. On success, navigates to `/change-phone-verify-email-otp` passing the email and OTP expiry data.
- **Localization:** All strings added to both `app_en.arb` and `app_ar.arb`

### Verify Email OTP Page (`/change-phone-verify-email-otp`)

- **Purpose:** Verify the OTP sent to the user's email
- **UI:** Reuses the existing OTP verification pattern (6-digit input, countdown timer, resend button) — same style as `ChangePhoneVerifyOtpView` and `ChangeEmailVerifyOtpView`
- **On verify:** Calls mocked verify API endpoint. On success, saves the email via `WalletAddressService.saveUserEmail()` (or updates user model), then auto-navigates to KYC flow.
- **Resend:** Calls the same mocked request endpoint to resend OTP
- **Localization:** All strings added to both ARB files

## KYC Integration

- Reuse existing `KycVerificationView`, `KycVerificationProvider`, and `KycVerificationService` as-is
- The KYC entry source enum (`KycVerificationEntrySource`) will get a new value (e.g., `changePhone`) so the KYC flow knows where to navigate back to on completion
- On KYC approval: auto-navigate to `/change-phone-intro`

## API Endpoints (Mocked)

Two new mocked endpoints in `endpoints.dart`:

- `CHANGE_PHONE_EMAIL_REQUEST` — `POST /v1/user/settings/change-phone/email/request`
  - Request body: `{ "email": "user@example.com" }`
  - Mocked response: `{ "masked_email": "u***@example.com", "otp_expiry_seconds": 60 }`

- `CHANGE_PHONE_EMAIL_VERIFY` — `POST /v1/user/settings/change-phone/email/verify`
  - Request body: `{ "email": "user@example.com", "otp": "123456" }`
  - Mocked response: `{ "success": true }`

These will be replaced with real endpoints later.

## New Files

| File | Purpose |
|------|---------|
| `lib/modules/settings/view/change_phone_number/change_phone_enter_email_view.dart` | Enter email screen |
| `lib/modules/settings/view/change_phone_number/change_phone_verify_email_otp_view.dart` | Verify email OTP screen |
| `lib/modules/settings/providers/change_phone_gate_provider.dart` | Gate logic — determines routing based on email/KYC status |
| `lib/modules/settings/providers/change_phone_email_provider.dart` | State management for email entry form |
| `lib/modules/settings/providers/change_phone_email_otp_provider.dart` | State management for email OTP verification |
| `lib/modules/settings/services/change_phone_email_service.dart` | Mocked API calls for email request/verify |

## Modified Files

| File | Change |
|------|--------|
| `lib/routes/app_routes.dart` | Add route constants for new screens |
| `lib/routes/app_router.dart` | Add route entries with providers for new screens |
| `lib/core/constants/endpoints.dart` | Add mocked endpoint paths |
| `lib/modules/kyc_verification/utils/kyc_verification_entry_source.dart` | Add `changePhone` entry source |
| `lib/modules/kyc_verification/providers/kyc_verification_provider.dart` | Handle `changePhone` source for post-KYC navigation |
| `assets/l10n/app_en.arb` | Add English strings for new screens |
| `assets/l10n/app_ar.arb` | Add Arabic strings for new screens |
| Settings screen (wherever "Change Phone" button lives) | Route through gate provider instead of directly to intro |

## Patterns to Follow

- **StatelessWidget + Provider** for all new screens
- **ReactiveTextField** for the email input (reactive_forms)
- **Freezed models** for any new API response models
- **Theme-driven styling** — no hardcoded colors
- **Localization-first** — all UI strings via `context.l10n`
- **Reuse existing widgets** — `ChangeDetailEnterNewView`, `ChangeDetailIntroView`, OTP patterns
- **CustomSvgPainterWidget** for any SVG icons

## Out of Scope

- Real API endpoint integration (mocked for now)
- Scenario C (user has email AND is KYC verified) — goes straight to existing flow, no changes needed
- Modifications to existing Change Phone screens
- Modifications to existing KYC form/SumSub integration beyond adding a new entry source
