import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';

/// Floating "Copied" pill shown after a clipboard copy. Use [CopiedToast.copy]
/// to copy + show in a single call; the toast auto-dismisses after [duration].
class CopiedToast extends StatelessWidget {
  const CopiedToast({super.key, required this.message});

  final String message;

  static const Duration _defaultDuration = Duration(seconds: 2);

  /// Trims [value], writes it to the clipboard, and shows the toast.
  /// Pass [message] to override the default localized "Copied" label.
  static void copy(
    BuildContext context,
    String value, {
    String? message,
    Duration duration = _defaultDuration,
  }) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    Clipboard.setData(ClipboardData(text: trimmed));
    show(context, message: message, duration: duration);
  }

  /// Shows the toast without touching the clipboard. Prefer [copy] for the
  /// common "copy + toast" flow.
  static void show(
    BuildContext context, {
    String? message,
    Duration duration = _defaultDuration,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    final resolved = message ?? context.l10n?.addressCopiedToast ?? 'Copied';
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 30 + bottomInset,
        left: 0,
        right: 0,
        child: Center(child: CopiedToast(message: resolved)),
      ),
    );
    overlay.insert(entry);
    Future.delayed(duration, () {
      if (entry.mounted) entry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.tealColor.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onInverseSurface,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
