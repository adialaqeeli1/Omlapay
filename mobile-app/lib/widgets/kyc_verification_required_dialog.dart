import 'package:flutter/material.dart';

import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';
import '../modules/kyc_verification/utils/kyc_status.dart';
import '../modules/kyc_verification/utils/kyc_verification_entry_source.dart';

/// Action the user took on the blocking KYC dialog.
enum KycDialogAction {
  /// User chose to start/retry verification ("Verify Now").
  verify,

  /// User chose to back out of the gated screen ("Go Back").
  dismiss,
}

/// Blocking KYC dialog shown as an overlay on the send / receive / swap flows
/// when the user's KYC is not approved. Replaces the old inline banner.
///
/// It mirrors the three banner states based on [kycStatus]:
/// - [KycStatus.notStarted] — module-specific prompt + "Verify Now" action.
/// - [KycStatus.pending] — informational "under review" message, no action.
/// - [KycStatus.rejected] — rejection reason + "Verify Now" action.
///
/// The dialog is non-dismissible by tapping the barrier; the user must either
/// proceed to verification or back out of the screen, keeping the screen's
/// actions blocked until KYC is completed.
class KycVerificationRequiredDialog extends StatelessWidget {
  const KycVerificationRequiredDialog({
    super.key,
    required this.kycStatus,
    required this.entrySource,
    this.rejectionReason,
    this.rejectionReasonAr,
  });

  final KycStatus kycStatus;
  final KycVerificationEntrySource entrySource;
  final String? rejectionReason;
  final String? rejectionReasonAr;

  /// Shows the blocking dialog and resolves with the [KycDialogAction] the user
  /// chose, or `null` if the dialog was dismissed without an explicit action.
  static Future<KycDialogAction?> show(
    BuildContext context, {
    required KycStatus kycStatus,
    required KycVerificationEntrySource entrySource,
    String? rejectionReason,
    String? rejectionReasonAr,
  }) {
    return showGeneralDialog<KycDialogAction>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) =>
          PopScope<KycDialogAction>(
            // Block the system back gesture so the screen stays gated; the user
            // must use one of the dialog actions.
            canPop: false,
            child: KycVerificationRequiredDialog(
              kycStatus: kycStatus,
              entrySource: entrySource,
              rejectionReason: rejectionReason,
              rejectionReasonAr: rejectionReasonAr,
            ),
          ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final isDark = context.isDarkMode;

    final dialogBg = isDark
        ? AppColors.darkCardColor
        : theme.colorScheme.surface.withValues(alpha: 0.98);
    final textColor = isDark ? AppColors.white : AppColors.textBlack;

    final bool isPending = kycStatus == KycStatus.pending;
    final String title = isPending
        ? l10n.kycVerificationPendingTitle
        : l10n.kycVerificationRequiredTitle;
    final IconData icon = isPending
        ? Icons.hourglass_top_rounded
        : Icons.error_outline;
    final Color iconColor = isPending
        ? AppColors.primaryColor
        : theme.colorScheme.error;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: dialogBg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _messageBody(context),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textColor.withValues(alpha: 0.85),
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              if (_showVerifyAction) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pop(KycDialogAction.verify),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.verifyNowButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(KycDialogAction.dismiss),
                  child: Text(
                    l10n.kycVerificationGoBackButton,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Whether the "Verify Now" action should be shown. Hidden while the KYC is
  /// pending review since there is no action the user can take.
  bool get _showVerifyAction =>
      kycStatus == KycStatus.notStarted || kycStatus == KycStatus.rejected;

  String _messageBody(BuildContext context) {
    final l10n = context.l10n!;

    switch (kycStatus) {
      case KycStatus.pending:
        return l10n.kyc_submitted_under_review;
      case KycStatus.rejected:
        final isArabic = Localizations.localeOf(context).languageCode == 'ar';
        final localizedReason = isArabic
            ? (rejectionReasonAr?.trim().isNotEmpty == true
                  ? rejectionReasonAr
                  : rejectionReason)
            : (rejectionReason?.trim().isNotEmpty == true
                  ? rejectionReason
                  : rejectionReasonAr);
        return localizedReason != null && localizedReason.isNotEmpty
            ? l10n.kyc_rejected_with_reason(localizedReason)
            : l10n.kyc_rejected;
      case KycStatus.notStarted:
      case KycStatus.approved:
        return _notStartedMessage(context);
    }
  }

  /// Returns the module-specific "not started" message based on [entrySource].
  String _notStartedMessage(BuildContext context) {
    final l10n = context.l10n!;
    switch (entrySource) {
      case KycVerificationEntrySource.send:
        return l10n.sendKycVerificationRequiredBody;
      case KycVerificationEntrySource.swap:
        return l10n.swapKycVerificationRequiredBody;
      case KycVerificationEntrySource.receive:
      case KycVerificationEntrySource.receiveHistory:
        return l10n.receiveKycVerificationRequiredBody;
      case KycVerificationEntrySource.profile:
      case KycVerificationEntrySource.unknown:
        return l10n.sendKycVerificationRequiredBody;
    }
  }
}
