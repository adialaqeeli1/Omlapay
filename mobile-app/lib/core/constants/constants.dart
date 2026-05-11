class AppConstants {
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String localeKey = 'app_locale';
  static const String themeModeKey = 'app_theme_mode';
  static const String notificationEnabledKey = 'notifications_enabled';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String dummyUsersKey = 'dummy_users_data';

  // App Lock
  static const int appLockBackgroundThresholdSeconds = 60;

  //Supported currencies
  static const List<String> supportedCurrencies = ['USD', 'SAR'];

  // Display precision for coin amounts (balances, send/receive/swap quantities).
  static const int coinAmountDecimals = 4;

  // Display precision for fiat values (USD / SAR).
  static const int fiatValueDecimals = 2;

  // Display precision for the min limit shown in send/swap amount hints.
  static const int minAmountDecimals = 4;

  // Display precision for the max limit shown in send/swap amount rows.
  static const int maxAmountDecimals = 2;
}
