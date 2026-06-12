import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Manages Shorebird over-the-air (code push) updates at runtime.
///
/// `auto_update` is left enabled in `shorebird.yaml`, so Shorebird downloads
/// patches in the background on launch and applies them on the next restart.
/// This provider adds the runtime layer on top:
///   * reads the currently-running patch number (shown in Settings),
///   * detects when a downloaded patch is pending a restart, and
///   * exposes [shouldShowRestartPrompt] so the UI can nudge the user.
///
/// When [ShorebirdUpdater.isAvailable] is false (debug builds, or releases not
/// built with `shorebird release`), every method is a no-op so behaviour is
/// unchanged in development.
class CodePushProvider extends ChangeNotifier {
  CodePushProvider({ShorebirdUpdater? updater})
    : _updater = updater ?? ShorebirdUpdater();

  final ShorebirdUpdater _updater;

  /// Whether the Shorebird updater is present in the current build.
  bool get isShorebirdAvailable => _updater.isAvailable;

  int? _currentPatchNumber;

  /// The patch number the app is currently running, or null if on the base
  /// release (no patch) or Shorebird is unavailable.
  int? get currentPatchNumber => _currentPatchNumber;

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  bool _isUpdateReadyToInstall = false;

  /// True once a patch has been downloaded and is waiting for the next app
  /// restart to take effect.
  bool get isUpdateReadyToInstall => _isUpdateReadyToInstall;

  /// Completes when the pending patch has finished downloading and is ready to
  /// install. The update dialog awaits this so its "OK" action only closes the
  /// app once Shorebird has finished its job. Completes with an error if the
  /// download fails, letting the dialog dismiss itself and restore navigation.
  Completer<void> _readyCompleter = Completer<void>();
  Future<void> get whenReadyToInstall => _readyCompleter.future;

  /// Completes once the first update check (including any download it triggers)
  /// has settled — i.e. we know whether an update will take over. The splash
  /// awaits this before navigating so it does not route away while a patch is
  /// downloading or ready to install.
  final Completer<void> _initialCheckCompleter = Completer<void>();
  Future<void> get initialCheckSettled => _initialCheckCompleter.future;

  void _markInitialCheckSettled() {
    if (!_initialCheckCompleter.isCompleted) _initialCheckCompleter.complete();
  }

  bool _updateDialogShown = false;

  /// The blocking update dialog should be shown exactly once per pending patch,
  /// as soon as a download starts (so navigation is blocked while it runs) or a
  /// patch is already downloaded. Call [markUpdateDialogShown] after presenting.
  bool get shouldShowUpdateDialog =>
      (_isDownloading || _isUpdateReadyToInstall) && !_updateDialogShown;

  bool _isChecking = false;

  /// Reads the current patch number for display. Safe to call repeatedly.
  Future<void> loadCurrentPatch() async {
    if (!_updater.isAvailable) return;
    try {
      final patch = await _updater.readCurrentPatch();
      if (patch?.number != _currentPatchNumber) {
        _currentPatchNumber = patch?.number;
        notifyListeners();
      }
    } catch (error) {
      debugPrint('CodePushProvider.loadCurrentPatch failed: $error');
    }
  }

  /// Checks for a new patch and, if one is available, downloads it. When a
  /// patch is downloaded (or was already downloaded by auto-update), flips
  /// [isUpdateReadyToInstall] so the UI can prompt for a restart.
  ///
  /// Failures (no network, etc.) are swallowed; the next check retries.
  Future<void> checkForUpdate() async {
    if (_isChecking || _isUpdateReadyToInstall) return;
    if (!_updater.isAvailable) {
      _markInitialCheckSettled();
      return;
    }
    _isChecking = true;
    try {
      final status = await _updater.checkForUpdate();
      switch (status) {
        case UpdateStatus.restartRequired:
          _markReadyToInstall();
        case UpdateStatus.outdated:
          await _downloadUpdate();
        case UpdateStatus.upToDate:
        case UpdateStatus.unavailable:
          break;
      }
    } catch (error) {
      debugPrint('CodePushProvider.checkForUpdate failed: $error');
    } finally {
      _isChecking = false;
      // Settle only after any download has resolved, so the splash sees the
      // final state (ready / failed / none) before deciding to navigate.
      _markInitialCheckSettled();
    }
  }

  Future<void> _downloadUpdate() async {
    // Flip downloading first so the blocking dialog is shown (and navigation
    // blocked) for the whole download, not only once it finishes.
    _isDownloading = true;
    notifyListeners();
    try {
      await _updater.update();
      _markReadyToInstall();
    } on UpdateException catch (error) {
      debugPrint('CodePushProvider update failed: ${error.message}');
      _handleDownloadFailure();
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  void _markReadyToInstall() {
    if (_isUpdateReadyToInstall) return;
    _isUpdateReadyToInstall = true;
    if (!_readyCompleter.isCompleted) _readyCompleter.complete();
    notifyListeners();
  }

  /// Releases a shown dialog when the download fails so the user is not left on
  /// a blocking, non-dismissible screen. Resets so a later check can retry and
  /// re-present the dialog with a fresh "ready" future.
  void _handleDownloadFailure() {
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.completeError(
        StateError('Shorebird update download failed'),
      );
    }
    _readyCompleter = Completer<void>();
    _updateDialogShown = false;
  }

  /// Marks the update dialog as shown so it is not presented again for the same
  /// pending patch.
  void markUpdateDialogShown() {
    _updateDialogShown = true;
  }
}
