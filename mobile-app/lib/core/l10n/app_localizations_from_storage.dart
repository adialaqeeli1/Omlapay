import 'package:flutter/widgets.dart';

import '../constants/constants.dart';
import '../services/storage_helper.dart';
import 'app_localizations.dart';

/// Resolves [AppLocalizations] from the user's saved language preference.
/// When no [BuildContext] is available, this matches [ApiMessageHelper]
/// locale detection (stored `'ar'` vs default English).
AppLocalizations appLocalizationsFromStoredLocale() {
  final saved = StorageService.getString(AppConstants.localeKey);
  final Locale locale =
      saved == 'ar' ? const Locale('ar') : const Locale('en');
  return lookupAppLocalizations(locale);
}
