import '../l10n/app_localizations.dart';

class AppException implements Exception {
  final String message;
  final String? messageKey;

  AppException(this.message, {this.messageKey});

  /// Resolves [messageKey] to a localized string using the given [l10n].
  /// Falls back to [message] if [messageKey] is null or not found.
  String localizedMessage(AppLocalizations? l10n) {
    if (l10n == null || messageKey == null) return message;
    return resolveErrorKey(l10n, messageKey!) ?? message;
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
