import 'package:flutter/foundation.dart';

import '../modules/kyc_verification/models/kyc_status_response.dart';
import '../modules/kyc_verification/services/kyc_verification_service.dart';
import '../modules/kyc_verification/utils/kyc_status.dart';
import 'auth_provider.dart';

class KycStatusProvider extends ChangeNotifier {
  KycStatusProvider(this._authProvider) {
    _authProvider.addListener(_onAuthChanged);
    // If user is already authenticated on construction (app restart),
    // fetch KYC status immediately so data is ready before any screen opens.
    _onAuthChanged();
  }

  final AuthProvider _authProvider;

  KycStatus _kycStatus = KycStatus.notStarted;
  String? _rejectionReason;
  String? _rejectionReasonAr;
  bool _isLoading = false;

  /// Tracks whether we've already fetched for the current session.
  /// Reset on logout so the next login triggers a fresh fetch.
  bool _hasFetched = false;

  /// Whether the KYC state has been definitively determined for the current
  /// session. Used to suppress the banner while the post-login fetch is still
  /// in flight, which would otherwise flash a stale "not started" banner to
  /// users whose KYC is actually approved.
  bool _isStatusResolved = false;

  KycStatus get kycStatus => _kycStatus;
  String? get rejectionReason => _rejectionReason;
  String? get rejectionReasonAr => _rejectionReasonAr;
  bool get isLoading => _isLoading;

  /// Whether the banner should be shown at all. Returns false until the
  /// current session's KYC status has been resolved, so callers never render
  /// a banner based on the default [KycStatus.notStarted] while the first
  /// fetch is still loading.
  bool get showBanner => _isStatusResolved && _kycStatus != KycStatus.approved;

  /// Whether the banner should show the "Verify Now" action.
  bool get showVerifyNowAction =>
      _kycStatus == KycStatus.notStarted || _kycStatus == KycStatus.rejected;

  void _onAuthChanged() {
    final user = _authProvider.state.user;

    // User logged out — reset state for next session.
    if (user == null || !_authProvider.state.isAuthenticated) {
      _kycStatus = KycStatus.notStarted;
      _rejectionReason = null;
      _rejectionReasonAr = null;
      _hasFetched = false;
      _isStatusResolved = false;
      notifyListeners();
      return;
    }

    // Already verified — set approved immediately, no API call needed.
    if (user.isVerified) {
      _kycStatus = KycStatus.approved;
      _rejectionReason = null;
      _rejectionReasonAr = null;
      _hasFetched = true;
      _isStatusResolved = true;
      notifyListeners();
      return;
    }

    // Authenticated but not verified — fetch once per session.
    if (!_hasFetched) {
      _fetchKycStatusOnce();
    }
  }

  /// Fetches KYC status exactly once. Called automatically after authentication.
  /// For manual re-fetch (e.g. after KYC submission), use [fetchKycStatus].
  Future<void> _fetchKycStatusOnce() async {
    _hasFetched = true;
    await _doFetch();
  }

  /// Optimistically marks the local status as `pending` (under review).
  /// Called right after a successful KYC resubmit so the home banner reflects
  /// the new state immediately — the backend response may still report
  /// `binance.status = 'REJECTED'` for a short window after resubmit while
  /// manual review processing catches up, which would otherwise cause
  /// `_deriveStatus` to flip back to `rejected` and show stale UI.
  void markAsPendingReview() {
    _kycStatus = KycStatus.pending;
    _rejectionReason = null;
    _isStatusResolved = true;
    _hasFetched = true;
    notifyListeners();
  }

  /// Public method to force a fresh fetch (e.g. after KYC submission flow).
  Future<void> fetchKycStatus() async {
    // Short-circuit: verified users don't need a status check.
    if (_authProvider.state.user?.isVerified == true) {
      _kycStatus = KycStatus.approved;
      _rejectionReason = null;
      _rejectionReasonAr = null;
      _isStatusResolved = true;
      notifyListeners();
      return;
    }
    await _doFetch();
  }

  Future<void> _doFetch() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await KycVerificationService.fetchKycStatus();
      _deriveStatus(response);
    } catch (e) {
      debugPrint('KycStatusProvider.fetchKycStatus failed: $e');
    } finally {
      _isLoading = false;
      _isStatusResolved = true;
      notifyListeners();
    }
  }

  void _deriveStatus(KycStatusResponse response) {
    final sumsubStatus = response.sumsub?.status?.toUpperCase();
    final binanceStatus = response.binance?.status?.toUpperCase();

    if (sumsubStatus != 'APPROVED') {
      // SumSub not approved (null or other) — KYC not started or in-progress.
      _kycStatus = KycStatus.notStarted;
      _rejectionReason = null;
      _rejectionReasonAr = null;
      return;
    }

    // SumSub is APPROVED — check Binance.
    if (binanceStatus == 'APPROVED') {
      _kycStatus = KycStatus.approved;
      _rejectionReason = null;
      _rejectionReasonAr = null;
      // Sync isVerified to auth provider so future checks skip the API call.
      _authProvider.verifyUser();
      return;
    }

    if (binanceStatus == 'REJECTED') {
      _kycStatus = KycStatus.rejected;
      _rejectionReason = response.binance?.rejectionReason;
      _rejectionReasonAr = response.binance?.rejectionReasonAr;
      return;
    }

    // SumSub APPROVED but Binance not yet decided — pending.
    _kycStatus = KycStatus.pending;
    _rejectionReason = null;
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }
}
