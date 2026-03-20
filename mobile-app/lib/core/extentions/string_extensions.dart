import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

import '../utils/utility.dart';

extension StringExt on String {
  String? getMimeType() => lookupMimeType(this);

  bool get isNum => Utility.isNum(this);

  bool get isNumericOnly => Utility.isNumericOnly(this);

  bool get isAlphabetOnly => Utility.isAlphabetOnly(this);

  bool get isBool => Utility.isBool(this);

  bool get isVectorFileName => Utility.isVector(this);

  bool get isImageFileName => Utility.isImage(this);

  bool get isSVG => Utility.isImage(this);

  bool get isAudioFileName => Utility.isAudio(this);

  bool get isVideoFileName => Utility.isVideo(this);

  bool get isTxtFileName => Utility.isTxt(this);

  bool get isDocumentFileName => Utility.isWord(this);

  bool get isExcelFileName => Utility.isExcel(this);

  bool get isPPTFileName => Utility.isPPT(this);

  bool get isAPKFileName => Utility.isAPK(this);

  bool get isPDFFileName => Utility.isPDF(this);

  bool get isHTMLFileName => Utility.isHTMLFile(this);

  bool get isHTML => Utility.isHTML(this);

  bool get isMarkdown => Utility.isMarkdown(this);

  bool get isURL => Utility.isURL(this);

  bool get isEmail => Utility.isEmail(this);

  bool get isPhoneNumber => Utility.isPhoneNumber(this);

  bool get isDateTime => Utility.isDateTime(this);

  bool get isMD5 => Utility.isMD5(this);

  bool get isSHA1 => Utility.isSHA1(this);

  bool get isSHA256 => Utility.isSHA256(this);

  bool get isBinary => Utility.isBinary(this);

  bool get isIPv4 => Utility.isIPv4(this);

  bool get isIPv6 => Utility.isIPv6(this);

  bool get isHexadecimal => Utility.isHexadecimal(this);

  bool get isPalindrom => Utility.isPalindrom(this);

  bool get isPassport => Utility.isPassport(this);

  bool get isCurrency => Utility.isCurrency(this);

  bool isCaseInsensitiveContains(String b) =>
      Utility.isCaseInsensitiveContains(this, b);

  bool isCaseInsensitiveContainsAny(String b) =>
      Utility.isCaseInsensitiveContainsAny(this, b);

  String? get capitalize => Utility.capitalize(this);

  String? get capitalizeFirst => Utility.capitalizeFirst(this);

  String get removeAllWhitespace => Utility.removeAllWhitespace(this);

  String? get snakeCase => Utility.snakeCase(this);

  String? get camelCase => Utility.camelCase(this);

  String? get paramCase => Utility.paramCase(this);

  String numericOnly({bool firstWordOnly = false}) =>
      Utility.numericOnly(this, firstWordOnly: firstWordOnly);

  Color? get hexToColor => Utility.hexStringToColor(this);
}

/// Masked national number for OTP screens, e.g. `+966 XXX XXX 1234`.
String maskedPhoneForDisplay(String countryCode, String digitsOnlyPhone) {
  final cc = countryCode.trim();
  final digits = digitsOnlyPhone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length < 4) {
    return '$cc XXX XXX XXXX';
  }
  final lastFour = digits.substring(digits.length - 4);
  return '$cc XXX XXX $lastFour';
}
