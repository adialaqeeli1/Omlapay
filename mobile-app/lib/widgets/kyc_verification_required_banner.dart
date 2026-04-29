import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';
import '../modules/kyc_verification/utils/kyc_status.dart';
import '../modules/kyc_verification/utils/kyc_verification_entry_source.dart';
import '../routes/app_router.dart';

/// Shared KYC banner shown across send / receive / swap flows.
///
/// Supports three visual states based on [kycStatus]:
/// - [KycStatus.notStarted] — red warning + "Verify Now" action.
/// - [KycStatus.pending] — informational banner, no action.
/// - [KycStatus.rejected] — red warning + rejection reason + "Verify Now" action.
class KycVerificationRequiredBanner extends StatelessWidget {
  const KycVerificationRequiredBanner({
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final isDark = context.isDarkMode;

    final String messageBody;
    final bool showAction;
    final IconData icon;

    final backgroundColor = isDark
        ? AppColors.kycVerificationBannerBackgroundDark
        : AppColors.kycVerificationBannerBackgroundLight;
    final foregroundColor = isDark
        ? AppColors.white
        : AppColors.kycBannerAccent;

    switch (kycStatus) {
      case KycStatus.notStarted:
        messageBody = _notStartedMessage(context);
        showAction = true;
        icon = Icons.error_outline;
      case KycStatus.pending:
        messageBody = l10n.kyc_submitted_under_review;
        showAction = false;
        icon = Icons.hourglass_top_rounded;
      case KycStatus.rejected:
        final isArabic =
            Localizations.localeOf(context).languageCode == 'ar';
        final localizedReason = isArabic
            ? (rejectionReasonAr?.trim().isNotEmpty == true
                  ? rejectionReasonAr
                  : rejectionReason)
            : (rejectionReason?.trim().isNotEmpty == true
                  ? rejectionReason
                  : rejectionReasonAr);
        messageBody =
            localizedReason != null && localizedReason.isNotEmpty
            ? l10n.kyc_rejected_with_reason(localizedReason)
            : l10n.kyc_rejected;
        showAction = true;
        icon = Icons.error_outline;
      case KycStatus.approved:
        // Should not be displayed, but handle gracefully.
        return const SizedBox.shrink();
    }

    final baseStyle = TextStyle(
      color: foregroundColor,
      fontSize: 13,
      height: 1.4,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foregroundColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: baseStyle,
                children: [
                  TextSpan(text: messageBody),
                  if (showAction) ...[
                    const TextSpan(text: ' '),
                    WidgetSpan(
                      child: InkWell(
                        onTap: () {
                          context.push(
                            Routes.kycVerification,
                            extra: entrySource,
                          );
                        },
                        child: Text(
                          l10n.verifyNowButton,
                          style: baseStyle.copyWith(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
