import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A [NavigatorObserver] that logs route transitions for debugging.
/// Logs are emitted only when [kDebugMode] is true.
class DebugRouteObserver extends NavigatorObserver {
  static const String _tag = '[Route]';

  void _log(String action, Route<dynamic> route, [Object? extra]) {
    if (!kDebugMode) return;
    final name = route.settings.name ?? route.settings.arguments?.toString() ?? 'unknown';
    final extraStr = extra != null ? ' | $extra' : '';
    debugPrint('$_tag $action: $name$extraStr');
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final prev = previousRoute?.settings.name ?? 'none';
    _log('PUSH', route, 'from: $prev');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final prev = previousRoute?.settings.name ?? 'none';
    _log('POP', route, 'to: $prev');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _log('REMOVE', route);
  }

  @override
  void didReplace({
    Route<dynamic>? newRoute,
    Route<dynamic>? oldRoute,
  }) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute != null) _log('REPLACE (old)', oldRoute);
    if (newRoute != null) _log('REPLACE (new)', newRoute);
  }
}
