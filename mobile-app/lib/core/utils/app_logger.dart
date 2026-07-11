import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Debug-only structured logging.
///
/// Forwards to `dart:developer`'s `log` with the exact same signature, but
/// becomes a no-op in profile and release builds. Use this instead of calling
/// `developer.log` / `log` directly so production builds never emit logs.
///
/// Note: `debugPrint` is silenced globally in non-debug builds from `main()`,
/// so plain `debugPrint(...)` calls are also debug-only.
void appLog(
  String message, {
  DateTime? time,
  int? sequenceNumber,
  int level = 0,
  String name = '',
  Zone? zone,
  Object? error,
  StackTrace? stackTrace,
}) {
  if (!kDebugMode) return;
  developer.log(
    message,
    time: time,
    sequenceNumber: sequenceNumber,
    level: level,
    name: name,
    zone: zone,
    error: error,
    stackTrace: stackTrace,
  );
}
