import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/code_push_provider.dart';
import '../routes/app_router.dart';
import 'update_ready_dialog.dart';

/// Wraps the app shell to drive Shorebird code-push checks and surface a
/// blocking update dialog while a patch downloads and until it is ready.
///
/// Checks run once after the first frame and again whenever the app resumes
/// from the background. When an update starts downloading (or one is already
/// downloaded), a one-time blocking dialog is shown that blocks navigation and
/// closes the app once the patch is ready. No-op when Shorebird is unavailable
/// (debug builds / non-Shorebird releases).
class CodePushListener extends StatefulWidget {
  const CodePushListener({required this.child, super.key});

  final Widget child;

  @override
  State<CodePushListener> createState() => _CodePushListenerState();
}

class _CodePushListenerState extends State<CodePushListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<CodePushProvider>();
      provider.loadCurrentPatch();
      provider.checkForUpdate();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<CodePushProvider>().checkForUpdate();
    }
  }

  void _maybeShowUpdateDialog(CodePushProvider provider) {
    if (!provider.shouldShowUpdateDialog) return;
    // Mark synchronously so the dialog is scheduled exactly once. This does not
    // notify listeners, so it cannot trigger a rebuild loop.
    provider.markUpdateDialogShown();

    // Capture the readiness future synchronously: on an immediate download
    // failure the provider swaps in a fresh completer, so reading it later (in
    // the post-frame callback) could hand the dialog a future that never
    // settles. The no-op handler ensures the error is always observed even if
    // the dialog is dismissed before it awaits.
    final readyFuture = provider.whenReadyToInstall..catchError((_) {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dialogContext = appNavigatorKey.currentContext;
      if (dialogContext == null) return;
      // A blocking, non-dismissible dialog shown for the whole update so all
      // navigation is blocked. Its "OK" action waits for the download to finish
      // before closing the app, so the patch applies on the next cold start.
      UpdateReadyDialog.show(dialogContext, whenReady: readyFuture);
    });
  }

  @override
  Widget build(BuildContext context) {
    _maybeShowUpdateDialog(context.watch<CodePushProvider>());
    return widget.child;
  }
}
