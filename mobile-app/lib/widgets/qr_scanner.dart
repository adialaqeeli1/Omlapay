import 'dart:async';
import 'package:omlapay_mobile_app/core/utils/app_logger.dart';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';
import '../core/utils/utility.dart';
import '../modules/scan/provider/qr_scanner_provider.dart';
import 'permission_dialog.dart';
import 'invalid_qr_code_dialog.dart';

/// A QR code scanner widget with camera permission handling.
///
/// Displays a full-screen camera preview for scanning QR codes. Handles
/// permission states: granted, denied, and permanently denied (with option
/// to open app settings).
///
/// [onScanned] is called with the raw string value when a QR code is
/// successfully scanned. The camera is stopped as soon as a code is detected
/// and stays stopped while the payload is validated, so a code is never
/// processed more than once. It only resumes if the user retries an invalid
/// code.
///
/// When [permissionProvider] is provided, permission logic is delegated to it.
/// Otherwise, the widget manages permission internally.
/// Async validator for a scanned QR code.
///
/// Returns `null` when the value is valid, or a [QrValidationError] describing
/// why it was rejected so the scanner can show a specific error message.
typedef QrCodeValidator = Future<QrValidationError?> Function(String value);

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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _hasScanned = false;
  bool _isValidating = false;
  ph.PermissionStatus _permissionStatus = ph.PermissionStatus.denied;
  bool _isCheckingPermission = true;
  bool _torchEnabled = false;
  late AnimationController _scanLineController;
  bool _hasShownPermissionDialog = false;

  bool get _useProvider => widget.permissionProvider != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null) return;
    // Release the camera as soon as the app loses focus (lock screen,
    // system task switcher, incoming call) so the hardware isn't held
    // while the user is somewhere else. `MobileScanner` will start it
    // again on rebuild when the app resumes.
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        unawaited(controller.stop().catchError((_) {}));
      case AppLifecycleState.resumed:
        unawaited(controller.start().catchError((_) {}));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanLineController.dispose();
    if (_useProvider) {
      widget.permissionProvider!.removeListener(_onProviderChanged);
    }
    // Stop first so the camera is released synchronously from the
    // platform's POV before `dispose()` tears down the controller. Without
    // the explicit stop, the platform's async `dispose()` can race with
    // the widget tree unmount and trigger
    // `BufferQueue has been abandoned` warnings in logcat.
    final controller = _controller;
    if (controller != null) {
      unawaited(controller.stop().catchError((_) {}));
      unawaited(controller.dispose());
      _controller = null;
    }
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
    appLog(
      'Camera: Checking permission (internal)',
      name: 'QrScannerWidget',
    );
    try {
      final status = await ph.Permission.camera.status;
      if (!mounted) return;
      _logPermissionStatus('Camera: Permission check completed', status);
      setState(() {
        _permissionStatus = status;
        _isCheckingPermission = false;
      });
    } catch (e, stackTrace) {
      appLog(
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
    appLog('$message: $statusStr', name: 'QrScannerWidget');
  }

  Future<void> _requestPermission() async {
    if (_useProvider) {
      await widget.permissionProvider!.requestPermission();
    } else {
      appLog(
        'Camera: Requesting permission from user (internal)',
        name: 'QrScannerWidget',
      );
      try {
        final status = await ph.Permission.camera.request();
        if (!mounted) return;
        _logPermissionStatus('Camera: Permission request result', status);
        setState(() => _permissionStatus = status);
      } catch (e, stackTrace) {
        appLog(
          'Camera: Error requesting permission: $e',
          name: 'QrScannerWidget',
          error: e,
          stackTrace: stackTrace,
        );
        if (!mounted) return;
      }
    }
  }

  Future<void> _showPermissionDialog() async {
    if (!mounted || _hasShownPermissionDialog) return;
    _hasShownPermissionDialog = true;

    final isPermanentlyDenied = _permissionStatus.isPermanentlyDenied;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialog(
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
      appLog(
        'Camera: Opening app settings (internal)',
        name: 'QrScannerWidget',
      );
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

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_hasScanned || _isValidating) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final rawValue = barcode.rawValue;
    final validator = widget.validator;

    // A QR/barcode was detected but its value couldn't be decoded (e.g. a
    // stylised or damaged code). Surface this as an invalid QR code instead
    // of silently ignoring it, so the user gets feedback and can retry.
    // Without a validator there is no error UI to show, so we just skip.
    if (rawValue == null || rawValue.isEmpty) {
      if (validator == null) return;
      appLog(
        'QR detect: rawValue is null/empty, showing invalid QR error',
        name: 'QrScannerWidget',
      );
      // Claim the detection synchronously so repeat frames don't stack
      // dialogs, then stop the camera while the error dialog is shown.
      _isValidating = true;
      await _controller?.stop();
      if (!mounted) return;
      _isValidating = false;
      await _showInvalidQrCodeDialog(QrValidationError.invalidFormat);
      return;
    }

    // Claim this detection synchronously — before the first `await` below — so
    // rapid repeat frames from the camera cannot start a second validation.
    // Then stop the camera entirely so no further frames are processed while
    // we verify the payload. It is resumed only if the user chooses to retry
    // an invalid code (see [_showInvalidQrCodeDialog]).
    if (validator != null) {
      setState(() => _isValidating = true);
    } else {
      _hasScanned = true;
    }
    await _controller?.stop();
    if (!mounted) return;

    if (validator != null) {
      appLog(
        'QR validate: running validator on "$rawValue"',
        name: 'QrScannerWidget',
      );
      final QrValidationError? error;
      try {
        error = await validator(rawValue);
      } finally {
        if (mounted) {
          setState(() => _isValidating = false);
        }
      }
      if (!mounted) return;
      appLog(
        'QR validate: result=${error ?? 'valid'} for "$rawValue"',
        name: 'QrScannerWidget',
      );
      if (error != null) {
        await _showInvalidQrCodeDialog(error);
        return;
      }
      _hasScanned = true;
    }

    appLog(
      'QR scanned: "$rawValue" (length: ${rawValue.length})',
      name: 'QrScannerWidget',
    );
    widget.onScanned(rawValue);
  }

  Future<void> _showInvalidQrCodeDialog(QrValidationError error) async {
    final l10n = context.l10n!;
    final message = switch (error) {
      QrValidationError.invalidFormat => l10n.invalidQrCode,
      QrValidationError.invalidAddress => l10n.qrInvalidWalletAddress,
      QrValidationError.networkError => l10n.qrAddressVerificationFailed,
      QrValidationError.addressNotValidated => l10n.qrAddressNotValidated,
    };
    final result = await InvalidQrCodeDialog.show(context, message: message);

    if (!mounted) return;
    if (result == true) {
      // Try again - resume the camera so the user can rescan. `_hasScanned`
      // and `_isValidating` are already false, so detection works normally.
      await _controller?.start();
    } else {
      // Cancel - pop the scanner
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final colorScheme = Theme.of(context).colorScheme;
    final title = widget.title ?? l10n.scanAQrCode;

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
      body: _buildBody(colorScheme),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (_isCheckingPermission) {
      return const SizedBox.shrink();
    }

    if (!_permissionStatus.isGranted) {
      if (!_hasShownPermissionDialog) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showPermissionDialog();
        });
      }
      return const SizedBox.shrink();
    }

    return _buildScannerView(colorScheme);
  }

  Widget _buildScannerView(ColorScheme colorScheme) {
    if (_controller == null) {
      appLog(
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
            appLog(
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
          child: Center(child: _buildTorchButton()),
        ),
        if (_isValidating) _buildValidationOverlay(),
      ],
    );
  }

  Widget _buildValidationOverlay() {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.55),
        child: const Center(
          child: SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ),
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
    final l10n = context.l10n!;

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
                l10n.cameraError,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.cameraErrorMessage,
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
