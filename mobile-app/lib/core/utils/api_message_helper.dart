import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../services/storage_helper.dart';

class ApiMessageHelper {
  static bool isArabicLocale({BuildContext? context}) {
    if (context != null) {
      return Localizations.localeOf(context).languageCode == 'ar';
    }
    return StorageService.getString(AppConstants.localeKey) == 'ar';
  }

  static String localizedFromResponse(
    Map<String, dynamic> response, {
    required String fallback,
    BuildContext? context,
  }) {
    final bool isArabic = isArabicLocale(context: context);
    final String preferredKey = isArabic ? 'message_ar' : 'message';
    final String secondaryKey = isArabic ? 'message' : 'message_ar';

    final String? preferredMessage = _readNonEmptyString(response[preferredKey]);
    if (preferredMessage != null) {
      return preferredMessage;
    }

    final String? secondaryMessage = _readNonEmptyString(response[secondaryKey]);
    if (secondaryMessage != null) {
      return secondaryMessage;
    }

    return fallback;
  }

  static String localizedText({
    required String message,
    required String messageAr,
    required String fallback,
    BuildContext? context,
  }) {
    final bool isArabic = isArabicLocale(context: context);
    final String primary = isArabic ? messageAr : message;
    final String secondary = isArabic ? message : messageAr;

    final String? normalizedPrimary = _readNonEmptyString(primary);
    if (normalizedPrimary != null) {
      return normalizedPrimary;
    }

    final String? normalizedSecondary = _readNonEmptyString(secondary);
    if (normalizedSecondary != null) {
      return normalizedSecondary;
    }

    return fallback;
  }

  static String? _readNonEmptyString(dynamic value) {
    final String? normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
