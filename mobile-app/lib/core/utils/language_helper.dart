import 'package:flutter/material.dart';
import '../../providers/locale_provider.dart';

/// Helper class for language switching
class LanguageHelper {
  static const Locale english = Locale('en');
  static const Locale arabic = Locale('ar');

  /// Switch to English
  static Future<void> switchToEnglish(LocaleProvider provider) async {
    await provider.setLocale(english);
  }

  /// Switch to Arabic
  static Future<void> switchToArabic(LocaleProvider provider) async {
    await provider.setLocale(arabic);
  }

  /// Toggle between English and Arabic
  static Future<void> toggleLanguage(LocaleProvider provider) async {
    if (provider.locale.languageCode == 'en') {
      await switchToArabic(provider);
    } else {
      await switchToEnglish(provider);
    }
  }
}
