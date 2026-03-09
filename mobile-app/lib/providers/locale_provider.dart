import 'package:flutter/material.dart';
import '../core/l10n/app_localizations.dart';
import '../core/services/storage_helper.dart';
import '../core/constants/constants.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  void _loadLocale() {
    final savedLocale = StorageService.getString(AppConstants.localeKey);
    if (savedLocale != null) {
      _locale = Locale(savedLocale);
    } else {
      _locale = const Locale('en');
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!AppLocalizations.supportedLocales.contains(locale)) return;

    _locale = locale;
    await StorageService.setString(AppConstants.localeKey, locale.languageCode);
    notifyListeners();
  }

  void clearLocale() {
    _locale = const Locale('en');
    StorageService.remove(AppConstants.localeKey);
    notifyListeners();
  }
}
