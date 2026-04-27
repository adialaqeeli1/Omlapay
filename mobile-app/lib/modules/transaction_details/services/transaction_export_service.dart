import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:gal/gal.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Outcome of a transaction export call.
///
/// `success` indicates the file made it to a destination the user can find.
/// `permissionDenied` is set true when the OS refused gallery access so the
/// caller can surface a dedicated, actionable message instead of a generic
/// failure toast.
class TransactionExportResult {
  const TransactionExportResult({
    required this.success,
    this.permissionDenied = false,
    this.cancelled = false,
  });

  final bool success;
  final bool permissionDenied;

  /// True when the user dismissed the save dialog without picking a
  /// destination. The caller should treat this as a silent no-op (no banner,
  /// no error toast) since it's a deliberate user action rather than a
  /// failure.
  final bool cancelled;
}

/// Renders the on-screen transaction receipt (anchored by a `RepaintBoundary`
/// key) into PNG / PDF and persists it.
///
/// PNG is written to the OS gallery via the `gal` plugin so the user can find
/// it in Photos / Gallery alongside their other media. PDF is handed to the
/// native save dialog (UIDocumentPicker on iOS, Storage Access Framework on
/// Android) so the user picks the destination directly — no share sheet
/// detour, and the file lands in Files / Downloads / iCloud / Drive / etc.
class TransactionExportService {
  TransactionExportService._();

  /// Captures the widget tree under [boundaryKey] and saves it as a PNG to
  /// the device gallery. Returns a [TransactionExportResult] describing the
  /// outcome so the caller can show a tailored message.
  static Future<TransactionExportResult> savePng({
    required GlobalKey boundaryKey,
    required String transactionId,
  }) async {
    final bytes = await _capturePng(boundaryKey);
    if (bytes == null) {
      return const TransactionExportResult(success: false);
    }

    try {
      final hasAccess = await Gal.hasAccess(toAlbum: false);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: false);
        if (!granted) {
          return const TransactionExportResult(
            success: false,
            permissionDenied: true,
          );
        }
      }

      await Gal.putImageBytes(
        bytes,
        name: 'omlapay_transaction_$transactionId',
      );
      return const TransactionExportResult(success: true);
    } on GalException catch (e) {
      return TransactionExportResult(
        success: false,
        permissionDenied: e.type == GalExceptionType.accessDenied,
      );
    } catch (_) {
      return const TransactionExportResult(success: false);
    }
  }

  /// Captures the widget tree under [boundaryKey], embeds the resulting image
  /// in a single-page PDF, then opens the native save dialog so the user can
  /// pick a destination (Files, iCloud Drive, Google Drive, Downloads, etc.).
  /// Returns `success: false` with no permission flag when the user cancels
  /// the dialog so the caller can stay quiet rather than show an error.
  static Future<TransactionExportResult> savePdf({
    required GlobalKey boundaryKey,
    required String transactionId,
  }) async {
    final bytes = await _capturePng(boundaryKey);
    if (bytes == null) {
      return const TransactionExportResult(success: false);
    }

    try {
      final pdfBytes = await _buildPdfFromImageBytes(bytes);
      final savedPath = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(
          data: pdfBytes,
          fileName: 'omlapay_transaction_$transactionId.pdf',
          mimeTypesFilter: const ['application/pdf'],
        ),
      );
      // `saveFile` returns null when the user dismissed the picker — that's
      // a cancel, not a failure, so we surface it via [cancelled] and the
      // caller skips both the success banner and the error toast.
      if (savedPath == null) {
        return const TransactionExportResult(
          success: false,
          cancelled: true,
        );
      }
      return const TransactionExportResult(success: true);
    } catch (_) {
      return const TransactionExportResult(success: false);
    }
  }

  /// Reads the rendered pixels behind [boundaryKey] and returns PNG bytes.
  /// Pixel ratio is bumped to 3.0 so the export stays crisp on retina /
  /// hi-DPI screens regardless of the device's native ratio.
  static Future<Uint8List?> _capturePng(GlobalKey boundaryKey) async {
    final boundary = boundaryKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return null;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return byteData?.buffer.asUint8List();
  }

  static Future<Uint8List> _buildPdfFromImageBytes(Uint8List pngBytes) async {
    final doc = pw.Document();
    final image = pw.MemoryImage(pngBytes);
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => pw.Center(
          child: pw.Image(image, fit: pw.BoxFit.contain),
        ),
      ),
    );
    return doc.save();
  }
}
