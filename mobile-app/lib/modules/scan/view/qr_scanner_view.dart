import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../widgets/qr_scanner.dart';
import '../provider/qr_scanner_provider.dart';

/// Extra payload for the QR scanner route.
class QrScannerExtra {
  const QrScannerExtra({this.validator, this.onScanned});

  final QrCodeValidator? validator;
  final ValueChanged<String>? onScanned;
}

/// Full-screen QR scanner view that uses [QrScannerProvider] for permission
/// logic and [QrScannerWidget] for the scanner UI.
///
/// Expects [GoRouterState.extra] to be:
/// - [QrScannerExtra] with optional validator and onScanned callback
/// - [ValueChanged<String>] for backward compatibility (onScanned only)
/// - null: scanned value is passed as route result via [context.pop]
class QrScannerView extends StatelessWidget {
  const QrScannerView({super.key, this.extra});

  final Object? extra;

  @override
  Widget build(BuildContext context) {
    final payload = _parseExtra(extra);
    final onScanned = payload.onScanned;

    return ChangeNotifierProvider(
      create: (_) => QrScannerProvider(),
      child: Builder(
        builder: (context) {
          return QrScannerWidget(
            permissionProvider: context.read<QrScannerProvider>(),
            validator: payload.validator,
            title: context.l10n!.scanAQrCode,
            onScanned: (value) {
              onScanned?.call(value);
              if (context.mounted) context.pop(value);
            },
          );
        },
      ),
    );
  }

  QrScannerExtra _parseExtra(Object? e) {
    if (e == null) return const QrScannerExtra();
    if (e is QrScannerExtra) return e;
    if (e is ValueChanged<String>) {
      return QrScannerExtra(onScanned: e);
    }
    return const QrScannerExtra();
  }
}
