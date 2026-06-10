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

  bool _restartPromptShown = false;

  /// The UI should show the "update ready" prompt exactly once per pending
  /// patch. Call [markRestartPromptShown] after presenting it.
  bool get shouldShowRestartPrompt =>
      _isUpdateReadyToInstall && !_restartPromptShown;

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
    if (!_updater.isAvailable || _isChecking || _isUpdateReadyToInstall) return;
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
    }
  }

  Future<void> _downloadUpdate() async {
    _isDownloading = true;
    notifyListeners();
    try {
      await _updater.update();
      _markReadyToInstall();
    } on UpdateException catch (error) {
      debugPrint('CodePushProvider update failed: ${error.message}');
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  void _markReadyToInstall() {
    if (_isUpdateReadyToInstall) return;
    _isUpdateReadyToInstall = true;
    notifyListeners();
  }

  /// Marks the restart prompt as shown so it is not presented again for the
  /// same pending patch.
  void markRestartPromptShown() {
    _restartPromptShown = true;
  }
}
