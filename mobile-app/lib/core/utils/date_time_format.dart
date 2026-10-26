import 'package:intl/intl.dart';

/// Single source of truth for full date-time stamps shown in the UI.
/// Example output: "2026-04-17 01:17 PM".
class AppDateTimeFormat {
  AppDateTimeFormat._();

  static const String dateTime = 'yyyy-MM-dd hh:mm a';
}

extension AppDateTimeFormatting on DateTime {
  /// Formats this DateTime as the standard app timestamp in the user's local
  /// time zone. Use this everywhere the UI needs a date + time stamp so the
  /// app stays visually consistent.
  String toAppDateTime() =>
      DateFormat(AppDateTimeFormat.dateTime).format(toLocal());
}
