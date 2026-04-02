import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';
import '../routes/app_router.dart';
import '../modules/kyc_verification/utils/kyc_verification_entry_source.dart';

/// Shared warning banner when the user must complete KYC before using
/// send / receive / swap (or similar) flows.
class KycVerificationRequiredBanner extends StatelessWidget {
  const KycVerificationRequiredBanner({
    super.key,
    required this.messageBody,
    required this.entrySource,
  });

  /// Localized sentence before the “Verify now” action (includes trailing space if needed).
  final String messageBody;

  /// Screen that surfaced this banner (used for KYC flow analytics / return context).
  final KycVerificationEntrySource entrySource;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final isDark = context.isDarkMode;
    final backgroundColor = isDark
        ? AppColors.kycVerificationBannerBackgroundDark
        : AppColors.kycVerificationBannerBackgroundLight;
    final foregroundColor = isDark
        ? AppColors.white
        : AppColors.kycBannerAccent;
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
          Icon(Icons.error_outline, color: foregroundColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: baseStyle,
                children: [
                  TextSpan(text: messageBody),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
