import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../core/extentions/context_extensions.dart';
import '../core/l10n/app_localizations.dart';
import '../core/theme/theme.dart';
import '../modules/scan/provider/qr_scanner_provider.dart';
import 'camera_permission_dialog.dart';
import 'invalid_qr_code_dialog.dart';

/// A QR code scanner widget with camera permission handling.
///
/// Displays a full-screen camera preview for scanning QR codes. Handles
/// permission states: granted, denied, and permanently denied (with option
/// to open app settings).
///
/// [onScanned] is called with the raw string value when a QR code is
/// successfully scanned. The scanner stops after the first successful scan
/// to prevent multiple callbacks.
///
/// When [permissionProvider] is provided, permission logic is delegated to it.
/// Otherwise, the widget manages permission internally.
/// Validator for scanned QR code. Returns true if valid, false if invalid.
typedef QrCodeValidator = bool Function(String value);

class QrScannerWidget extends StatefulWidget {
  /// Callback invoked when a QR code is successfully scanned.
  final ValueChanged<String> onScanned;

  /// Optional title shown in the app bar.
  final String? title;

  /// Optional provider for permission handling. When provided, permission
  /// logic is delegated to the provider instead of internal state.
  final QrScannerProvider? permissionProvider;

  /// Optional validator. When provided, scanned values are validated.
  /// If invalid, [InvalidQrCodeDialog] is shown and the user can try again.
  final QrCodeValidator? validator;

  const QrScannerWidget({
    super.key,
    required this.onScanned,
    this.title,
    this.permissionProvider,
    this.validator,
  });

  @override
  State<QrScannerWidget> createState() => _QrScannerWidgetState();
}

class _QrScannerWidgetState extends State<QrScannerWidget>
    with SingleTickerProviderStateMixin {
  MobileScannerController? _controller;
  bool _hasScanned = false;
  ph.PermissionStatus _permissionStatus = ph.PermissionStatus.denied;
  bool _isCheckingPermission = true;
  bool _torchEnabled = false;
  late AnimationController _scanLineController;
  bool _hasShownPermissionDialog = false;

  bool get _useProvider => widget.permissionProvider != null;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    if (_useProvider) {
      widget.permissionProvider!.addListener(_onProviderChanged);
      _syncFromProvider();
    } else {
      _checkPermission();
    }
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    if (_useProvider) {
      widget.permissionProvider!.removeListener(_onProviderChanged);
    }
    _controller?.dispose();
    super.dispose();
  }

  void _onProviderChanged() {
    if (mounted) _syncFromProvider();
  }

  void _syncFromProvider() {
    final p = widget.permissionProvider!;
    setState(() {
      _permissionStatus = p.permissionStatus;
      _isCheckingPermission = p.isCheckingPermission;
    });
  }

  Future<void> _checkPermission() async {
    if (_useProvider) return;
    developer.log('Camera: Checking permission (internal)', name: 'QrScannerWidget');
    try {
      final status = await ph.Permission.camera.status;
      if (!mounted) return;
      _logPermissionStatus('Camera: Permission check completed', status);
      setState(() {
        _permissionStatus = status;
        _isCheckingPermission = false;
      });
    } catch (e, stackTrace) {
      developer.log(
        'Camera: Error checking permission: $e',
        name: 'QrScannerWidget',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() => _isCheckingPermission = false);
    }
  }

  void _logPermissionStatus(String message, ph.PermissionStatus status) {
    final statusStr = status.isGranted
        ? 'granted'
        : status.isPermanentlyDenied
            ? 'permanentlyDenied'
            : status.isDenied
                ? 'denied'
                : status.isRestricted
                    ? 'restricted'
                    : 'unknown';
    developer.log('$message: $statusStr', name: 'QrScannerWidget');
  }

  Future<void> _requestPermission() async {
    if (_useProvider) {
      await widget.permissionProvider!.requestPermission();
    } else {
      developer.log('Camera: Requesting permission from user (internal)', name: 'QrScannerWidget');
      try {
        final status = await ph.Permission.camera.request();
        if (!mounted) return;
        _logPermissionStatus('Camera: Permission request result', status);
        setState(() => _permissionStatus = status);
      } catch (e, stackTrace) {
        developer.log(
          'Camera: Error requesting permission: $e',
          name: 'QrScannerWidget',
          error: e,
          stackTrace: stackTrace,
        );
        if (!mounted) return;
      }
    }
  }

  Future<void> _showCameraPermissionDialog() async {
    if (!mounted || _hasShownPermissionDialog) return;
    _hasShownPermissionDialog = true;

    final isPermanentlyDenied = _permissionStatus.isPermanentlyDenied;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CameraPermissionDialog(
        onAllow: isPermanentlyDenied
            ? null
            : () => Navigator.of(context).pop(true),
        onOpenSettings: isPermanentlyDenied
            ? () => Navigator.of(context).pop(true)
            : null,
        onDoNotAllow: () => Navigator.of(context).pop(false),
      ),
    );

    if (!mounted) return;
    if (result == true) {
      if (isPermanentlyDenied) {
        _hasShownPermissionDialog = false;
        await _openAppSettings();
      } else {
        await _requestPermission();
        if (mounted) {
          final granted = _useProvider
              ? widget.permissionProvider!.isPermissionGranted
              : _permissionStatus.isGranted;
          if (!granted) _hasShownPermissionDialog = false;
        }
      }
    } else {
      context.pop();
    }
  }

  Future<void> _openAppSettings() async {
    if (_useProvider) {
      await widget.permissionProvider!.openSettings();
    } else {
      developer.log('Camera: Opening app settings (internal)', name: 'QrScannerWidget');
      await ph.openAppSettings();
      if (!mounted) return;
      setState(() => _isCheckingPermission = true);
      await _checkPermission();
    }
  }

  void _toggleTorch() {
    _controller?.toggleTorch();
    setState(() => _torchEnabled = !_torchEnabled);
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final rawValue = barcode.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    final validator = widget.validator;
    if (validator != null && !validator(rawValue)) {
      _showInvalidQrCodeDialog();
      return;
    }

    _hasScanned = true;
    developer.log(
      'Camera: QR code scanned successfully (length: ${rawValue.length})',
      name: 'QrScannerWidget',
    );
    widget.onScanned(rawValue);
  }

  Future<void> _showInvalidQrCodeDialog() async {
    final result = await InvalidQrCodeDialog.show(context);

    if (!mounted) return;
    if (result == true) {
      // Try again - allow scanning again (no-op, _hasScanned stays false)
    } else {
      // Cancel - pop the scanner
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final title = widget.title ?? l10n?.scanAQrCode ?? l10n?.qrCodeScanner ?? 'Scan a QR Code';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: _buildBody(colorScheme, l10n),
    );
  }

  Widget _buildBody(ColorScheme colorScheme, AppLocalizations? l10n) {
    if (_isCheckingPermission) {
      return const SizedBox.shrink();
    }

    if (!_permissionStatus.isGranted) {
      if (!_hasShownPermissionDialog) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showCameraPermissionDialog();
        });
      }
      return const SizedBox.shrink();
    }

    return _buildScannerView(colorScheme);
  }

  Widget _buildScannerView(ColorScheme colorScheme) {
    if (_controller == null) {
      developer.log(
        'Camera: Permission granted, starting scanner',
        name: 'QrScannerWidget',
      );
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: _controller!,
          onDetect: _onDetect,
          errorBuilder: (context, error) {
          developer.log(
            'Camera: Scanner error - code: ${error.errorCode}, details: ${error.errorDetails}',
            name: 'QrScannerWidget',
            error: error,
          );
          return _buildCameraErrorView(context, colorScheme, error);
        },
        ),
        _buildScanOverlay(),
        Positioned(
          left: 0,
          right: 0,
          bottom: 40,
          child: Center(
            child: _buildTorchButton(),
          ),
        ),
      ],
    );
  }

  Widget _buildScanOverlay() {
    return Center(
      child: SizedBox(
        width: 260,
        height: 260,
        child: AnimatedBuilder(
          animation: _scanLineController,
          builder: (context, child) {
            return CustomPaint(
              painter: _ScanOverlayPainter(
                cornerColor: Colors.white,
                scanLineColor: AppColors.tealColor,
                progress: _scanLineController.value,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTorchButton() {
    return Material(
      color: Colors.black.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _toggleTorch,
        customBorder: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          child: Icon(
            _torchEnabled ? Icons.flash_on : Icons.flash_on_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildCameraErrorView(
    BuildContext context,
    ColorScheme colorScheme,
    MobileScannerException error,
  ) {
    final l10n = context.l10n;

    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 24),
              Text(
                l10n?.cameraError ?? 'Camera error',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n?.cameraErrorMessage ??
                    'Unable to access the camera. Please try again.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints white corner brackets and animated teal scan line.
class _ScanOverlayPainter extends CustomPainter {
  _ScanOverlayPainter({
    required this.cornerColor,
    required this.scanLineColor,
    required this.progress,
  });

  final Color cornerColor;
  final Color scanLineColor;
  final double progress;

  static const double _cornerLength = 28;
  static const double _cornerRadius = 8;
  static const double _strokeWidth = 3;
  static const double _scanLineHeight = 2;

  @override
  void paint(Canvas canvas, Size size) {
    _drawCorners(canvas, size);
    _drawScanLine(canvas, size);
  }

  void _drawCorners(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cornerColor
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Top-left (rounded)
    path.moveTo(_cornerRadius, 0);
    path.lineTo(_cornerLength, 0);
    path.moveTo(0, _cornerRadius);
    path.lineTo(0, _cornerLength);

    // Top-right
    path.moveTo(size.width - _cornerLength, 0);
    path.lineTo(size.width - _cornerRadius, 0);
    path.moveTo(size.width, _cornerRadius);
    path.lineTo(size.width, _cornerLength);

    // Bottom-right
    path.moveTo(size.width, size.height - _cornerLength);
    path.lineTo(size.width, size.height - _cornerRadius);
    path.moveTo(size.width - _cornerRadius, size.height);
    path.lineTo(size.width - _cornerLength, size.height);

    // Bottom-left
    path.moveTo(_cornerLength, size.height);
    path.lineTo(_cornerRadius, size.height);
    path.moveTo(0, size.height - _cornerLength);
    path.lineTo(0, size.height - _cornerRadius);

    canvas.drawPath(path, paint);
  }

  void _drawScanLine(Canvas canvas, Size size) {
    final y = size.height * 0.33 + (size.height * 0.34) * progress;

    final paint = Paint()
      ..color = scanLineColor
      ..strokeWidth = _scanLineHeight
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.cornerColor != cornerColor ||
        oldDelegate.scanLineColor != scanLineColor;
  }
}
