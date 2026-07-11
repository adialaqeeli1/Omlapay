import 'package:flutter/material.dart';
import '../core/constants/endpoints.dart';
import '../core/l10n/app_localizations.dart';
import '../core/services/api_helper.dart';
import '../core/services/storage_helper.dart';
import '../core/constants/constants.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  bool _hasFetchedLanguage = false;
  bool _isAuthenticated = false;

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

  void onAuthChanged(bool isAuthenticated) {
    _isAuthenticated = isAuthenticated;
    if (isAuthenticated) {
      if (!_hasFetchedLanguage) {
        _fetchLanguageSetting();
      }
    } else {
      _hasFetchedLanguage = false;
    }
  }

  Future<void> _fetchLanguageSetting() async {
    _hasFetchedLanguage = true;

    try {
      final response = await ApiHelper.get(Endpoints.userSettingsLanguage);
      final language = response['data']?['language'] as String?;

      if (language != null) {
        final serverLocale = Locale(language);
        if (_locale != serverLocale) {
          // Local language differs from server — local choice wins.
          // Push local language to server, then confirm by fetching back.
          await _updateLanguageSetting(_locale.languageCode);
          await _refreshLanguageFromServer();
        }
      }
    } catch (_) {
      // API failed, keep locally saved locale
    }
  }

  Future<void> _refreshLanguageFromServer() async {
    try {
      final response = await ApiHelper.get(Endpoints.userSettingsLanguage);
      final language = response['data']?['language'] as String?;
      if (language != null) {
        final serverLocale = Locale(language);
        if (AppLocalizations.supportedLocales.contains(serverLocale) &&
            _locale != serverLocale) {
          _locale = serverLocale;
          await StorageService.setString(AppConstants.localeKey, language);
          notifyListeners();
        }
      }
    } catch (_) {
      // API failed, keep current locale
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!AppLocalizations.supportedLocales.contains(locale)) return;

    _locale = locale;
    await StorageService.setString(AppConstants.localeKey, locale.languageCode);
    notifyListeners();

    if (_isAuthenticated) {
      _updateLanguageSetting(locale.languageCode);
    }
  }

  Future<void> _updateLanguageSetting(String language) async {
    try {
      await ApiHelper.put(
        Endpoints.userSettingsLanguage,
        {'language': language},
      );
    } catch (_) {
      // API failed, language is already saved locally
    }
  }

  void clearLocale() {
    _locale = const Locale('en');
    StorageService.remove(AppConstants.localeKey);
    notifyListeners();
  }
}
