/// API endpoint paths and base URL configuration for OmlaPay backend.
class Endpoints {
  /// Protocol for API requests.
  static String get protocol => 'https';

  /// API host domain.
  static String get domain => 'api.omlapay.xyz';

  /// Full base URL for all API requests (e.g. https://api.omlapay.xyz).
  static String get baseUrl => '$protocol://$domain';

  /// API version prefix used in paths.
  static String get apiVersion => '/v1';

  /// User Registration
  static String get registerRequest => '$apiVersion/user/register/request';
  static String get registerResendOtp => '$apiVersion/user/register/resend-otp';
  static String get registerVerifyOtp => '$apiVersion/user/register/verify-otp';
  static String get registerSetPasscode =>
      '$apiVersion/user/register/set-passcode';

  /// Auth
  static String get login => '$apiVersion/auth/login';
  static String get softLogin => '$apiVersion/auth/soft-login';
  static String get checkUser => '$apiVersion/auth/check-user';
  static String get inviteUser => '$apiVersion/user/invite';
  static String get home => '$apiVersion/home';
  static String get sessionStatus => '$apiVersion/auth/session-status';
  static String get forgotPasscode => '$apiVersion/auth/forgot-passcode';
  static String get forgotPasscodeResendOtp =>
      '$apiVersion/auth/forgot-passcode/resend-otp';
  static String get forgotPasscodeVerifyOtp =>
      '$apiVersion/auth/forgot-passcode/verify-otp';
  static String get forgotPasscodeReset => '$apiVersion/auth/forgot-passcode/reset';
  static String get changePasscode => '$apiVersion/user/settings/change-passcode';

  /// Settings → change phone (4-step flow).
  static String get changePhoneStep1Request =>
      '$apiVersion/user/settings/change-phone/step1-request';
  static String get changePhoneStep2Verify =>
      '$apiVersion/user/settings/change-phone/step2-verify';
  static String get changePhoneStep3Request =>
      '$apiVersion/user/settings/change-phone/step3-request';
  static String get changePhoneStep4Verify =>
      '$apiVersion/user/settings/change-phone/step4-verify';

  /// Settings → change email (5-step flow).
  static String get changeEmailStep1Request =>
      '$apiVersion/user/settings/change-email/step1-request';
  static String get changeEmailStep2Verify =>
      '$apiVersion/user/settings/change-email/step2-verify';
  static String get changeEmailStep3Request =>
      '$apiVersion/user/settings/change-email/step3-request';
  static String get changeEmailStep4Verify =>
      '$apiVersion/user/settings/change-email/step4-verify';
  static String get changeEmailStep5Confirm =>
      '$apiVersion/user/settings/change-email/step5-confirm';

  /// List coins with prices; supports query param `currency` (e.g. /v1/coins?currency=usd).
  static String get coins => '$apiVersion/coins';

  /// Sync coin metadata and active status from upstream; POST with empty body.
  static String get coinsSync => '$coins/sync';

  /// SSE stream for real-time coin price updates; supports query param `currency`.
  static String get coinsPricesStream => '$coins/prices/stream';

  /// Receive wallets grouped by network and coin addresses.
  static String get receiveWallets => '$apiVersion/receive/wallets';

  /// Receive transaction history; supports query params `limit` and `cursor`.
  static String get receiveHistory => '$apiVersion/receive/history';

  /// Full transaction history; supports query params `asset`, `type`,
  /// `limit`, `after`, `startDate`, `endDate`.
  static String get history => '$apiVersion/history';

  /// Single transaction detail by id.
  static String historyDetail(String id) => '$apiVersion/history/$id';

  /// Validates a wallet address for a given coin before sending.
  /// Query params: `address` (required), `coin` (required).
  static String get sendValidateAddress =>
      '$apiVersion/send/validate-address';

  /// Returns authoritative fee/amount quote for a prospective send.
  /// Query params: `coin`, `recipient`, `amount` (all required).
  static String get sendQuote => '$apiVersion/send/quote';

  /// Initiates a send transfer; triggers an OTP to the user's registered phone.
  /// Body: `coin`, `recipient`, `amount`, `network`.
  static String get sendInitiate => '$apiVersion/send/initiate';

  /// Resends the OTP for an ongoing send flow.
  /// Body: `sendToken`.
  static String get sendResendOtp => '$apiVersion/send/resend-otp';

  /// Confirms a pending send with the OTP received on the user's phone.
  /// Body: `sendToken`, `otp`.
  static String get sendConfirm => '$apiVersion/send/confirm';

  /// Returns a swap quote for converting between two coins.
  /// Query params: `fromCoin`, `toCoin`, `amount` (all required).
  static String get swapQuote => '$apiVersion/swap/quote';

  /// SSE stream for real-time swap quote updates; query params
  /// `fromCoin`, `toCoin`, `amount`, `currency` (all required).
  static String get swapQuoteStream => '$apiVersion/swap/quote/stream';

  /// Executes a swap between two coins.
  /// Body: `fromCoin`, `toCoin`, `amount` (all required).
  static String get swapExecute => '$apiVersion/swap/execute';

  /// KYC start endpoint; returns Sumsub access token.
  static String get kycStart => '$apiVersion/user/kyc/start';

  /// Binance KYC start endpoint; initiates Binance verification after Sumsub approval.
  static String get kycBinanceStart => '$apiVersion/user/kyc/binance/start';

  /// KYC status endpoint; returns sumsub and binance verification statuses.
  static String get kycStatus => '$apiVersion/user/kyc/status';

  /// KYC rejection details; returns previously submitted data for form prefill
  /// when the user is retrying after a rejection.
  static String get kycRejectionDetails =>
      '$apiVersion/user/kyc/rejection-details';

  /// KYC resubmit; called instead of `kycStart` when the user is re-submitting
  /// after a rejection. Reuses existing SumSub documents on the server side.
  static String get kycResubmit => '$apiVersion/user/kyc/resubmit';

  /// Email verification: request OTP for email address.
  static String get emailRequest => '$apiVersion/user/email/request';

  /// Email verification: verify OTP for email address.
  static String get emailVerify => '$apiVersion/user/email/verify';

  /// User account details endpoint.
  static String get accountDetails => '$apiVersion/user/account-details';

  /// Register an FCM device token for push notifications.
  /// Body: `device_token`, `device_model`, `device_uuid`.
  static String get pushNotificationDevices =>
      '$apiVersion/notifications/devices';

  /// Notifications; supports query params `limit` and `cursor`.
  static String get notifications => '$apiVersion/notifications';

  /// Mark a single notification as read.
  static String notificationRead(String id) =>
      '$apiVersion/notifications/$id/read';

  /// Mark all notifications as read.
  static String get notificationsMarkAllRead =>
      '$apiVersion/notifications/mark-all-read';

  /// Legal documents; supports query param `language` (e.g. en, ar).
  static String get legalPrivacy => '$apiVersion/legal/privacy';
  static String get legalTerms => '$apiVersion/legal/terms';
  static String get legalFaqs => '$apiVersion/legal/faqs';

  /// About content; supports query param `language` (e.g. en, ar).
  static String get about => '$apiVersion/about';
  static String get twoFactorEnable =>
      '$apiVersion/user/settings/2fa/enable';
  static String get twoFactorDisable =>
      '$apiVersion/user/settings/2fa/disable';
  static String get userSettingsCurrency => '$apiVersion/user/settings/currency';
  static String get userSettingsAppearance =>
      '$apiVersion/user/settings/appearance';
  static String get userSettingsLanguage =>
      '$apiVersion/user/settings/language';

  /// File upload; supports query param `prefix` (e.g. support-requests).
  static String get upload => '$apiVersion/user/upload';

  /// Support requests; supports query params `status`, `page`, `limit`.
  static String get supportRequests => '$apiVersion/user/support-requests';

  /// Single support request detail; path param {id}.
  static String supportRequestDetail(String id) =>
      '$apiVersion/user/support-requests/$id';

  /// Reopen a support request; path param {id}.
  static String supportRequestReopen(String id) =>
      '$apiVersion/user/support-requests/$id/reopen';
}
