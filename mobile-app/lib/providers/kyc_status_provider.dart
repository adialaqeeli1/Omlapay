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
  bool _isLoading = false;

  /// Tracks whether we've already fetched for the current session.
  /// Reset on logout so the next login triggers a fresh fetch.
  bool _hasFetched = false;

  KycStatus get kycStatus => _kycStatus;
  String? get rejectionReason => _rejectionReason;
  bool get isLoading => _isLoading;

  /// Whether the banner should be shown at all.
  bool get showBanner => _kycStatus != KycStatus.approved;

  /// Whether the banner should show the "Verify Now" action.
  bool get showVerifyNowAction =>
      _kycStatus == KycStatus.notStarted || _kycStatus == KycStatus.rejected;

  void _onAuthChanged() {
    final user = _authProvider.state.user;

    // User logged out — reset state for next session.
    if (user == null || !_authProvider.state.isAuthenticated) {
      _kycStatus = KycStatus.notStarted;
      _rejectionReason = null;
      _hasFetched = false;
      notifyListeners();
      return;
    }

    // Already verified — set approved immediately, no API call needed.
    if (user.isVerified) {
      _kycStatus = KycStatus.approved;
      _rejectionReason = null;
      _hasFetched = true;
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

  /// Public method to force a fresh fetch (e.g. after KYC submission flow).
  Future<void> fetchKycStatus() async {
    // Short-circuit: verified users don't need a status check.
    if (_authProvider.state.user?.isVerified == true) {
      _kycStatus = KycStatus.approved;
      _rejectionReason = null;
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
      return;
    }

    // SumSub is APPROVED — check Binance.
    if (binanceStatus == 'APPROVED') {
      _kycStatus = KycStatus.approved;
      _rejectionReason = null;
      // Sync isVerified to auth provider so future checks skip the API call.
      _authProvider.verifyUser();
      return;
    }

    if (binanceStatus == 'REJECTED') {
      _kycStatus = KycStatus.rejected;
      _rejectionReason = response.binance?.rejectionReason;
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
