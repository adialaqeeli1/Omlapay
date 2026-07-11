import '../l10n/app_localizations.dart';

class AppException implements Exception {
  final String message;
  final String? messageKey;

  AppException(this.message, {this.messageKey});

  /// Whether this failure specifically describes an invalid/expired OTP.
  ///
  /// The backend returns generic `400`s with `messageKey: 'requestFailed'` and
  /// a human-readable message for BOTH OTP rejections and unrelated failures
  /// (e.g. "Transfer failed. Please try again."), with no machine-readable
  /// error code to tell them apart. So OTP rejections are classified from the
  /// localized message text. Callers use this to decide whether to surface an
  /// OTP-field error vs. a generic snackbar only.
  bool get isInvalidOtp {
    if (messageKey == 'invalidOtpTryAgain') return true;
    final lower = message.toLowerCase();
    if (lower.contains('otp')) return true;
    final mentionsCodeEn = lower.contains('verification code') ||
        (lower.contains('code') &&
            (lower.contains('invalid') ||
                lower.contains('incorrect') ||
                lower.contains('wrong') ||
                lower.contains('expired')));
    if (mentionsCodeEn) return true;
    // Arabic: "رمز" (code) qualified as invalid/wrong/expired.
    return message.contains('رمز') &&
        (message.contains('غير صالح') ||
            message.contains('خاطئ') ||
            message.contains('منتهي'));
  }

  /// Returns the best user-facing error text.
  ///
  /// Priority:
  /// 1. The server-provided [message] (already locale-aware via ApiHelper)
  ///    — used when it differs from the generic [messageKey] resolution.
  /// 2. The ARB string resolved from [messageKey] — used as fallback when
  ///    [message] is empty or looks like a raw network/framework string.
  String localizedMessage(AppLocalizations? l10n) {
    final resolvedKey =
        (l10n != null && messageKey != null) ? resolveErrorKey(l10n, messageKey!) : null;
    // If the server provided a meaningful message, prefer it over the generic
    // ARB key string. Fall back to the ARB key when message is absent.
    if (message.trim().isNotEmpty) return message;
    return resolvedKey ?? message;
  }

  /// Resolves an error key string to a localized message.
  /// Returns null if the key is not recognized.
  static String? resolveErrorKey(AppLocalizations l10n, String key) {
    return switch (key) {
      'networkError' => l10n.networkError,
      'requestFailed' => l10n.requestFailed,
      'unknownError' => l10n.unknownError,
      'invalidOtpTryAgain' => l10n.invalidOtpTryAgain,
      'invalidServerResponse' => l10n.invalidServerResponse,
      'softLoginFailed' => l10n.softLoginFailed,
      'registrationFailed' => l10n.registrationFailed,
      'unableToChangePasscode' => l10n.unableToChangePasscode,
      'somethingWentWrong' => l10n.somethingWentWrong,
      'failedToLoadNotifications' => l10n.failedToLoadNotifications,
      'failedToLoadMoreNotifications' => l10n.failedToLoadMoreNotifications,
      'failedToMarkNotificationAsRead' => l10n.failedToMarkNotificationAsRead,
      'failedToMarkAllNotificationsAsRead' =>
        l10n.failedToMarkAllNotificationsAsRead,
      'failedToLoadSupportRequests' => l10n.failedToLoadSupportRequests,
      'failedToLoadMoreRequests' => l10n.failedToLoadMoreRequests,
      _ => null,
    };
  }

  @override
  String toString() => message;
}
