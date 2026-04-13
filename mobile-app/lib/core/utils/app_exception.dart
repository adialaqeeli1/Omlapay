import '../l10n/app_localizations.dart';

class AppException implements Exception {
  final String message;
  final String? messageKey;

  AppException(this.message, {this.messageKey});

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
