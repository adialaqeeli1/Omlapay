import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common_back_button.dart';

class ChangePhoneSuccessView extends StatelessWidget {
  const ChangePhoneSuccessView({super.key});

  void _goHome(BuildContext context) {
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final accent = AppColors.greenColor;
    final badgeFill = theme.brightness == Brightness.dark
        ? const Color(0xFF1A3D3A)
        : theme.colorScheme.primary.withValues(alpha: 0.22);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goHome(context);
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          leading: CommonBackButton(onPressed: () => _goHome(context)),
          title: Text(
            l10n.changePhoneNumber,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SuccessBadge(accent: accent, badgeFill: badgeFill),
                        const SizedBox(height: 32),
                        Text(
                          l10n.phoneNumberChangedSuccessfully,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () => _goHome(context),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: theme.brightness == Brightness.dark
                        ? AppColors.iconBackground
                        : theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: theme.colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.backHome,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge({required this.accent, required this.badgeFill});

  final Color accent;
  final Color badgeFill;

  @override
  Widget build(BuildContext context) {
    const outer = 132.0;
    const inner = 108.0;
    return SizedBox(
      width: outer + 24,
      height: outer + 24,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 4,
            right: 8,
            child: Icon(Icons.star, size: 14, color: accent.withValues(alpha: 0.9)),
          ),
          Positioned(
            bottom: 14,
            left: 0,
            child: Icon(Icons.star, size: 11, color: accent.withValues(alpha: 0.75)),
          ),
          Container(
            width: outer,
            height: outer,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.65), width: 1.5),
            ),
          ),
          Container(
            width: inner,
            height: inner,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badgeFill,
              border: Border.all(color: accent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.25),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Icon(Icons.check_rounded, size: 52, color: accent),
          ),
        ],
      ),
    );
  }
}
