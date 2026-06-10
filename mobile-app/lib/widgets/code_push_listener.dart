import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/code_push_provider.dart';
import '../routes/app_router.dart';
import 'update_ready_dialog.dart';

/// Wraps the app shell to drive Shorebird code-push checks and surface a
/// restart prompt when a patch has been downloaded.
///
/// Checks run once after the first frame and again whenever the app resumes
/// from the background. When a patch is ready, a one-time localized snackbar
/// informs the user it will apply on the next launch. No-op when Shorebird is
/// unavailable (debug builds / non-Shorebird releases).
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

  void _maybeShowRestartPrompt(CodePushProvider provider) {
    if (!provider.shouldShowRestartPrompt) return;
    // Mark synchronously so the prompt is scheduled exactly once. This does not
    // notify listeners, so it cannot trigger a rebuild loop.
    provider.markRestartPromptShown();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dialogContext = appNavigatorKey.currentContext;
      if (dialogContext == null) return;
      // A blocking, non-dismissible dialog. Tapping "OK" closes the app so the
      // downloaded patch is applied on the next cold start.
      UpdateReadyDialog.show(
        dialogContext,
        onConfirm: UpdateReadyDialog.closeApp,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _maybeShowRestartPrompt(context.watch<CodePushProvider>());
    return widget.child;
  }
}
