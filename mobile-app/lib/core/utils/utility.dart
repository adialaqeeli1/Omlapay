import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_helper;

import '../constants/endpoints.dart';
import '../models/wallet_model/wallet_model.dart';
import '../services/api_helper.dart';

/// Reason a scanned QR code failed validation.
///
/// `null` return from [Utility.isValidWalletAddress] means the value is valid;
/// any non-null value tells the caller which error message to surface.
enum QrValidationError {
  /// Payload is not JSON or does not match the expected wallet-coin shape.
  invalidFormat,

  /// The embedded address failed the client-side format regex.
  invalidAddress,

  /// Backend validation request failed due to network/connectivity issues.
  networkError,

  /// Backend explicitly rejected the address.
  addressNotValidated,
}

class Utility {
  static RegExp alphaNumericPasswordRegex = RegExp(
    r"^(?=.*[a-zA-Z])(?=.*[0-9]).{6,}$",
  );

  static RegExp phoneRegex = RegExp(
    r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$',
  );

  static bool? isEmpty(dynamic value) {
    if (value is String) {
      return value.toString().trim().isEmpty;
    }
    if (value is Iterable || value is Map) {
      return value.isEmpty as bool?;
    }
    return false;
  }

  static bool isCaseInsensitiveContains(String a, String b) {
    return a.toLowerCase().contains(b.toLowerCase());
  }

  static bool isCaseInsensitiveContainsAny(String a, String b) {
    final lowA = a.toLowerCase();
    final lowB = b.toLowerCase();

    return lowA.contains(lowB) || lowB.contains(lowA);
  }

  static String? capitalizeFirst(String s) {
    if (isNull(s)) return null;
    if (isBlank(s)!) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  static String? capitalize(String value) {
    if (isNull(value)) return null;
    if (isBlank(value)!) return value;
    return value.split(' ').map(capitalizeFirst).join(' ');
  }

  static String removeAllWhitespace(String value) {
    return value.replaceAll(' ', '');
  }

  static String? camelCase(String value) {
    if (isNullOrBlank(value)!) {
      return null;
    }

    final separatedWords = value.split(
      RegExp(r'[!@#<>?":`~;[\]\\|=+)(*&^%-\s_]+'),
    );
    var newString = '';

    for (final word in separatedWords) {
      newString += word[0].toUpperCase() + word.substring(1).toLowerCase();
    }

    return newString[0].toLowerCase() + newString.substring(1);
  }

  static final RegExp _upperAlphaRegex = RegExp(r'[A-Z]');
  static final _symbolSet = {' ', '.', '/', '_', '\\', '-'};

  static List<String> _groupIntoWords(String text) {
    var sb = StringBuffer();
    var words = <String>[];
    var isAllCaps = text.toUpperCase() == text;

    for (var i = 0; i < text.length; i++) {
      var char = text[i];
      var nextChar = i + 1 == text.length ? null : text[i + 1];
      if (_symbolSet.contains(char)) {
        continue;
      }
      sb.write(char);
      var isEndOfWord =
          nextChar == null ||
          (_upperAlphaRegex.hasMatch(nextChar) && !isAllCaps) ||
          _symbolSet.contains(nextChar);
      if (isEndOfWord) {
        words.add('$sb');
        sb.clear();
      }
    }
    return words;
  }

  static String? snakeCase(String? text, {String separator = '_'}) {
    if (isNullOrBlank(text)!) {
      return null;
    }
    return _groupIntoWords(
      text!,
    ).map((word) => word.toLowerCase()).join(separator);
  }

  static String? paramCase(String? text) => snakeCase(text, separator: '-');

  static String numericOnly(String s, {bool firstWordOnly = false}) {
    var numericOnlyStr = '';

    for (var i = 0; i < s.length; i++) {
      if (isNumericOnly(s[i])) {
        numericOnlyStr += s[i];
      }
      if (firstWordOnly && numericOnlyStr.isNotEmpty && s[i] == " ") {
        break;
      }
    }

    return numericOnlyStr;
  }

  static bool isNull(dynamic value) => value == null;

  static bool? isNullOrBlank(dynamic value) {
    if (isNull(value)) {
      return true;
    }

    return isEmpty(value);
  }

  static bool? isBlank(dynamic value) {
    return isEmpty(value);
  }

  static bool hasMatch(String? value, String pattern) {
    return (value == null) ? false : RegExp(pattern).hasMatch(value);
  }

  static bool isNumericOnly(String s) => hasMatch(s, r'^\d+$');

  static bool isAlphabetOnly(String s) => hasMatch(s, r'^[a-zA-Z]+$');

  static bool isNum(String value) {
    if (isNull(value)) {
      return false;
    }

    return num.tryParse(value) is num;
  }

  static bool isBool(String value) {
    if (isNull(value)) {
      return false;
    }

    return (value == 'true' || value == 'false');
  }

  static bool isVector(String filePath) {
    return filePath.toLowerCase().endsWith(".svg");
  }

  static bool isImage(String filePath) {
    const List<String> imageExtensions = <String>[
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp',
      'tif',
      'tiff',
      'gif',
      'ico',
      'svg',
      'webp',
    ];

    final ext = path_helper
        .extension(filePath)
        .toLowerCase()
        .replaceAll('.', '');
    return imageExtensions.contains(ext);
  }

  static bool isSVG(String filePath) {
    const List<String> imageExtensions = <String>['svg'];

    final ext = path_helper
        .extension(filePath)
        .toLowerCase()
        .replaceAll('.', '');
    return imageExtensions.contains(ext);
  }

  static bool isAudio(String filePath) {
    const List<String> audioExtensions = <String>[
      'mp3',
      'wav',
      'wma',
      'amr',
      'ogg',
      'aac',
      'flac',
      'm4a',
      'aiff',
      'aif',
    ];

    final ext = path_helper
        .extension(filePath)
        .toLowerCase()
        .replaceAll('.', '');

    return audioExtensions.contains(ext);
  }

  static bool isVideo(String filePath) {
    const List<String> videoExtensions = <String>[
      'mp4',
      'avi',
      'wmv',
      'rmvb',
      'mpg',
      'mpeg',
      '3gp',
      'mov',
      'mkv',
      'flv',
      'ogg',
      'webm',
    ];

    final ext = path_helper
        .extension(filePath)
        .toLowerCase()
        .replaceAll('.', '');

    return videoExtensions.contains(ext);
  }

  static bool isTxt(String filePath) => filePath.toLowerCase().endsWith(".txt");

  static bool isWord(String filePath) {
    const List<String> wordExtensions = <String>[
      'doc',
      'docx',
      'dot',
      'dotx',
      'rtf',
      'odt',
      'ott',
      'wps',
      'wpt',
    ];

    final ext = path_helper
        .extension(filePath)
        .toLowerCase()
        .replaceAll('.', '');

    return wordExtensions.contains(ext);
  }

  static bool isExcel(String filePath) {
    const List<String> excelExtensions = <String>['xls', 'xlsx', 'xlsb', 'csv'];

    final ext = path_helper
        .extension(filePath)
        .toLowerCase()
        .replaceAll('.', '');

    return excelExtensions.contains(ext);
  }

  static bool isPPT(String filePath) {
    const List<String> pptExtensions = ['ppt', 'pptx', 'pps', 'ppsx'];

    final ext = path_helper
        .extension(filePath)
        .toLowerCase()
        .replaceAll('.', '');

    return pptExtensions.contains(ext);
  }

  static bool isAPK(String filePath) =>
      path_helper.extension(filePath).toLowerCase() == '.apk';

  static bool isPDF(String filePath) =>
      path_helper.extension(filePath).toLowerCase() == '.pdf';

  static bool isHTMLFile(String filePath) {
    const List<String> htmlExtensions = <String>['html', 'htm'];

    final ext = path_helper
        .extension(filePath)
        .toLowerCase()
        .replaceAll('.', '');

    return htmlExtensions.contains(ext);
  }

  static bool isHTML(String filePath) {
    final htmlRegex = RegExp(
      r'<([a-z][a-z0-9]*)\b[^>]*>(.*?)</\1>',
      caseSensitive: false,
      multiLine: true,
    );

    return htmlRegex.hasMatch(filePath);
  }

  static bool isMarkdown(String text) {
    final markdownRegex = RegExp(
      r'(^|\s)([#_*`\-~]{1,6}|\[.*\]\(.*\)|\*{1,2}.*\*{1,2}|\~{2}.*\~{2}|`.*`)',
      multiLine: true,
    );
    return markdownRegex.hasMatch(text);
  }

  static bool isURL(String s) => hasMatch(
    s,
    r'^(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})',
  );

  static bool isEmail(String s) => hasMatch(
    s,
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  );

  static bool isPhoneNumber(String s) {
    if (s.length > 16 || s.length < 9) return false;
    return hasMatch(s, phoneRegex.pattern);
  }

  static bool isDateTime(String s) =>
      hasMatch(s, r'^\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}:\d{2}.\d{3}Z?$');

  static bool isMD5(String s) => hasMatch(s, r'^[a-f0-9]{32}$');

  static bool isSHA1(String s) =>
      hasMatch(s, r'(([A-Fa-f0-9]{2}\:){19}[A-Fa-f0-9]{2}|[A-Fa-f0-9]{40})');

  static bool isSHA256(String s) =>
      hasMatch(s, r'([A-Fa-f0-9]{2}\:){31}[A-Fa-f0-9]{2}|[A-Fa-f0-9]{64}');

  static bool isSSN(String s) => hasMatch(
    s,
    r'^(?!0{3}|6{3}|9[0-9]{2})[0-9]{3}-?(?!0{2})[0-9]{2}-?(?!0{4})[0-9]{4}$',
  );

  static bool isBinary(String s) => hasMatch(s, r'^[0-1]+$');

  static bool isIPv4(String s) =>
      hasMatch(s, r'^(?:(?:^|\.)(?:2(?:5[0-5]|[0-4]\d)|1?\d?\d)){4}$');

  static bool isIPv6(String s) => hasMatch(
    s,
    r'^((([0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}:[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){5}:([0-9A-Fa-f]{1,4}:)?[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){4}:([0-9A-Fa-f]{1,4}:){0,2}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){3}:([0-9A-Fa-f]{1,4}:){0,3}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){2}:([0-9A-Fa-f]{1,4}:){0,4}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}((\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b)\.){3}(\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b))|(([0-9A-Fa-f]{1,4}:){0,5}:((\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b)\.){3}(\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b))|(::([0-9A-Fa-f]{1,4}:){0,5}((\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b)\.){3}(\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b))|([0-9A-Fa-f]{1,4}::([0-9A-Fa-f]{1,4}:){0,5}[0-9A-Fa-f]{1,4})|(::([0-9A-Fa-f]{1,4}:){0,6}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){1,7}:))$',
  );

  static bool isHexadecimal(String s) =>
      hasMatch(s, r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$');

  static bool isPalindrom(String string) {
    final cleanString = string
        .toLowerCase()
        .replaceAll(RegExp(r"\s+"), '')
        .replaceAll(RegExp(r"[^0-9a-zA-Z]+"), "");

    for (var i = 0; i < cleanString.length; i++) {
      if (cleanString[i] != cleanString[cleanString.length - i - 1]) {
        return false;
      }
    }

    return true;
  }

  static bool isPassport(String s) =>
      hasMatch(s, r'^(?!^0+$)[a-zA-Z0-9]{6,9}$');

  static bool isCurrency(String s) => hasMatch(
    s,
    r'^(S?\$|\₩|Rp|\¥|\€|\₹|\₽|fr|R\$|R)?[ ]?[-]?([0-9]{1,3}[,.]([0-9]{3}[,.])*[0-9]{3}|[0-9]+)([,.][0-9]{1,2})?( ?(USD?|AUD|NZD|CAD|CHF|GBP|CNY|EUR|JPY|IDR|MXN|NOK|KRW|TRY|INR|RUB|BRL|ZAR|SGD|MYR))?$',
  );

  static double clampDouble(double x, double min, double max) {
    assert(min <= max && !max.isNaN && !min.isNaN);
    if (x < min) {
      return min;
    }
    if (x > max) {
      return max;
    }
    if (x.isNaN) {
      return max;
    }
    return x;
  }

  static Color getRandomColor() {
    Random random = Random();
    int red = random.nextInt(256);
    int green = random.nextInt(256);
    int blue = random.nextInt(256);

    return Color.fromRGBO(red, green, blue, 1.0);
  }

  static String getFileSize({
    required int contentLength,
    int fixedDecimals = 0,
  }) {
    final int bytes = contentLength;
    const List<String> suffixes = ["b", "kb", "mb", "gb", "tb"];
    var i = (math.log(bytes) / math.log(1024)).floor();

    return '${((bytes / math.pow(1024, i)).toStringAsFixed(fixedDecimals))} ${suffixes[i]}';
  }

  static Color? hexStringToColor(String hexString) {
    int? colorInt = int.tryParse(hexString.replaceAll('#', '0xff'));

    if (colorInt != null) {
      return Color(colorInt);
    }

    return null;
  }

  static String getCryptoCoinIconFromSymbol(String symbol) {
    return "https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/${symbol.toLowerCase()}.png";
  }

  /// Validates a scanned QR payload that should encode a [WalletCoinModel].
  ///
  /// Returns `null` if the payload is a well-formed wallet JSON, its address
  /// matches a known chain format, and the backend accepts it. Otherwise
  /// returns a [QrValidationError] describing what went wrong so callers can
  /// show a specific error message.
  ///
  /// Steps:
  /// 1. `jsonDecode` the raw value — must be a `Map<String, dynamic>`.
  /// 2. Parse into [WalletCoinModel] and require non-empty `symbol`/`address`.
  /// 3. Run client-side regex on the address (cheap local reject).
  /// 4. Call `GET /v1/send/validate-address?address=...&coin=...` and require
  ///    a non-null `data` payload.
  static Future<QrValidationError?> isValidWalletAddress(String value) async {
    final dynamic decoded;
    try {
      decoded = jsonDecode(value);
    } catch (_) {
      return QrValidationError.invalidFormat;
    }
    if (decoded is! Map<String, dynamic>) {
      return QrValidationError.invalidFormat;
    }

    final WalletCoinModel wallet;
    try {
      wallet = WalletCoinModel.fromJson(decoded);
    } catch (_) {
      return QrValidationError.invalidFormat;
    }

    final symbol = wallet.symbol.trim();
    final address = wallet.address?.trim() ?? '';
    if (symbol.isEmpty || address.isEmpty) {
      return QrValidationError.invalidFormat;
    }

    if (!_matchesKnownAddressFormat(address)) {
      return QrValidationError.invalidAddress;
    }

    try {
      final response = await ApiHelper.get(
        Endpoints.sendValidateAddress,
        queryParameters: {'address': address, 'coin': symbol},
      );
      final data = response['data'];
      if (data is! Map<String, dynamic> || data.isEmpty) {
        return QrValidationError.addressNotValidated;
      }
      return null;
    } catch (e, stackTrace) {
      developer.log(
        'validate-address request failed: $e',
        name: 'Utility.isValidWalletAddress',
        error: e,
        stackTrace: stackTrace,
      );
      return QrValidationError.networkError;
    }
  }

  /// Client-side regex check covering EVM (0x...), Bitcoin (1, 3, bc1),
  /// Tron (T...), and Solana (base58) address formats.
  static bool _matchesKnownAddressFormat(String address) {
    if (address.isEmpty || address.length < 20) return false;

    if (address.startsWith('0x') && address.length == 42) {
      return RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(address);
    }

    if (address.startsWith('1') || address.startsWith('3')) {
      return RegExp(r'^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$').hasMatch(address);
    }
    if (address.startsWith('bc1')) {
      return address.length >= 42 && address.length <= 62;
    }

    if (address.startsWith('T') && address.length == 34) {
      return RegExp(r'^T[0-9a-fA-F]{33}$').hasMatch(address);
    }

    if (RegExp(r'^[1-9A-HJ-NP-Za-km-z]{32,44}$').hasMatch(address)) {
      return true;
    }

    return false;
  }
}
