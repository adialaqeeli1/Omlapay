import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../modules/kyc_verification/utils/kyc_status.dart';
import '../modules/kyc_verification/utils/kyc_verification_entry_source.dart';
import '../providers/kyc_status_provider.dart';
import '../routes/app_router.dart';
import 'kyc_verification_required_dialog.dart';

/// Invisible trigger that gates a send / receive / swap screen behind a blocking
/// KYC dialog when the user's KYC is not approved.
///
/// Place it anywhere in the screen's widget tree (it renders nothing). While
/// [KycStatusProvider.showBanner] is true and this screen is the current route,
/// it presents [KycVerificationRequiredDialog] as a non-dismissible overlay,
/// keeping the screen's actions blocked until the user either proceeds to
/// verification or backs out of the screen.
class KycVerificationGate extends StatefulWidget {
  const KycVerificationGate({
    super.key,
    required this.entrySource,
    this.forceShow = false,
  });

  final KycVerificationEntrySource entrySource;

  /// Additional condition (beyond [KycStatusProvider.showBanner]) that forces
  /// the gate to engage — e.g. the receive flow's wallet-level KYC requirement.
  final bool forceShow;

  @override
  State<KycVerificationGate> createState() => _KycVerificationGateState();
}

class _KycVerificationGateState extends State<KycVerificationGate> {
  bool _isDialogOpen = false;

  @override
  Widget build(BuildContext context) {
    final kyc = context.watch<KycStatusProvider>();
    // Never gate an approved user, even if a caller forces the gate on.
    final shouldGate =
        kyc.kycStatus != KycStatus.approved &&
        (widget.forceShow || kyc.showBanner);
    if (shouldGate) {
      _maybeShowDialog(kyc);
    }
    return const SizedBox.shrink();
  }

  void _maybeShowDialog(KycStatusProvider kyc) {
    if (_isDialogOpen) return;

    // Don't stack a dialog when this screen isn't the visible route (e.g. the
    // KYC verification screen is on top after the user tapped "Verify Now").
    final route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) return;

    _isDialogOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final action = await KycVerificationRequiredDialog.show(
        context,
        kycStatus: kyc.kycStatus,
        entrySource: widget.entrySource,
        rejectionReason: kyc.rejectionReason,
        rejectionReasonAr: kyc.rejectionReasonAr,
      );

      if (!mounted) {
        _isDialogOpen = false;
        return;
      }
      _isDialogOpen = false;

      switch (action) {
        case KycDialogAction.verify:
          context.push(Routes.kycVerification, extra: widget.entrySource);
        case KycDialogAction.dismiss:
        case null:
          // Back out of the gated screen so its actions stay blocked.
          if (context.canPop()) context.pop();
      }
    });
  }
}
