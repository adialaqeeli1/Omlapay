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
  static String get sessionStatus => '$apiVersion/auth/session-status';
  static String get forgotPasscode => '$apiVersion/auth/forgot-passcode';
  static String get forgotPasscodeResendOtp =>
      '$apiVersion/auth/forgot-passcode/resend-otp';
  static String get forgotPasscodeVerifyOtp =>
      '$apiVersion/auth/forgot-passcode/verify-otp';
  static String get forgotPasscodeReset => '$apiVersion/auth/forgot-passcode/reset';
  static String get changePasscode => '$apiVersion/user/settings/change-passcode';

  /// Settings → change phone: send OTP to the new number, then verify.
  static String get changePhoneRequest =>
      '$apiVersion/user/settings/change-phone/request';
  static String get changePhoneVerify =>
      '$apiVersion/user/settings/change-phone/verify';

  /// Settings → change email: send OTP to new address, then verify.
  static String get changeEmailRequest =>
      '$apiVersion/user/settings/change-email/request';
  static String get changeEmailVerify =>
      '$apiVersion/user/settings/change-email/verify';

  /// List coins with prices; supports query param `currency` (e.g. /v1/coins?currency=usd).
  static String get coins => '$apiVersion/coins';

  /// Sync coin metadata and active status from upstream; POST with empty body.
  static String get coinsSync => '$coins/sync';

  /// SSE stream for real-time coin price updates; supports query param `currency`.
  static String get coinsPricesStream => '$coins/prices/stream';

  /// Receive wallets grouped by network and coin addresses.
  static String get receiveWallets => '$apiVersion/receive/wallets';

  /// KYC start endpoint; returns Sumsub access token.
  static String get kycStart => '$apiVersion/user/kyc/start';

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
  static String get userSettingsCurrency => '$apiVersion/user/settings/currency';
  static String get userSettingsAppearance =>
      '$apiVersion/user/settings/appearance';
  static String get userSettingsLanguage =>
      '$apiVersion/user/settings/language';
}
