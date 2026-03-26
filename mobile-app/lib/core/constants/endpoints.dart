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

  /// List coins with prices; supports query param `currency` (e.g. /v1/coins?currency=usd).
  static String get coins => '$apiVersion/coins';

  /// Sync coin metadata and active status from upstream; POST with empty body.
  static String get coinsSync => '$coins/sync';

  /// SSE stream for real-time coin price updates; supports query param `currency`.
  static String get coinsPricesStream => '$coins/prices/stream';
}
