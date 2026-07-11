import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../core/constants/constants.dart';
import '../core/l10n/app_localizations_from_storage.dart';
import '../core/models/auth_state/auth_state.dart';
import '../core/models/user_model/user_model.dart';
import '../core/models/wallet_model/wallet_model.dart';
import '../core/mock_data/mock_data.dart';
import '../core/services/push_notification_service.dart';
import '../core/services/storage_helper.dart';
import '../core/utils/api_message_helper.dart';
import '../core/utils/app_exception.dart';
import '../core/utils/user_auth_phone.dart';
import '../modules/auth/providers/passcode_provider.dart';
import '../modules/auth/services/auth_service.dart';
import '../modules/auth/services/forgot_passcode_service.dart';
import '../modules/settings/services/wallet_address_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthState _state = const AuthState();
  AuthState get state => _state;

  /// Optional hook invoked after a successful [login] or [softLogin].
  /// Set by [AppLockProvider] so the lock state machine can flip to "unlocked"
  /// without [AuthProvider] taking a hard dependency on it.
  VoidCallback? onUnlockCallback;

  bool _isApiSuccess(Map<String, dynamic> response) {
    final statusCode = response['statusCode'];
    if (statusCode is int && statusCode >= 200 && statusCode < 300) {
      return true;
    }

    final status = response['status']?.toString();
    if (status == 'success') {
      return true;
    }

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return data['status']?.toString() == 'success';
    }

    return false;
  }

  String _localizedMessageFromRawResponse(
    Map<String, dynamic> response, {
    required String fallback,
  }) {
    return ApiMessageHelper.localizedFromResponse(response, fallback: fallback);
  }

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final userJson = StorageService.getString(AppConstants.userKey);
    if (userJson != null) {
      try {
        final user = UserModel.fromJson(jsonDecode(userJson));
        _state = state.copyWith(authStatus: AuthStatus.authorized, user: user);
      } catch (e) {
        _state = state.copyWith(authStatus: AuthStatus.unauthorized);
      }
    } else {
      _state = state.copyWith(authStatus: AuthStatus.unauthorized);
    }
    notifyListeners();
  }

  Future<bool> login({
    required String passcode,
    required String otpVerificationToken,
  }) async {
    try {
      _state = state.copyWith(isLoading: true, errorMessage: null);
      notifyListeners();

      final rawResponse = await AuthService.login(
        passcode: passcode,
        otpVerificationToken: otpVerificationToken,
      );

      final int? statusCode = rawResponse['statusCode'] as int?;
      final bool isSuccess =
          (statusCode != null && statusCode >= 200 && statusCode < 300) ||
          rawResponse['status']?.toString() == 'success';
      final Map<String, dynamic>? data =
          rawResponse['data'] is Map<String, dynamic>
          ? rawResponse['data'] as Map<String, dynamic>
          : null;
      final String? accessToken = data?['access_token']?.toString();
      final String? refreshToken = data?['refresh_token']?.toString();
      final dynamic userData = data?['user'];
      final Map<String, dynamic>? userJson = userData is Map<String, dynamic>
          ? userData
          : null;
      final UserModel? user = userJson != null
          ? UserModel.fromJson(userJson)
          : null;

      if (isSuccess &&
          user != null &&
          accessToken != null &&
          accessToken.isNotEmpty) {
        // The OTP login API returns `user.mobile_number` as the full combined
        // number (e.g. "+917709922711") with no separate `country_code` field,
        // so the parsed UserModel has empty `countryCode` / `mobileNumber`.
        // Derive the parts from `fullMobileNumber` so silent-relogin flows
        // (disable 2FA, change passcode, etc.) have valid credentials to send.
        final parts = (user.countryCode.isEmpty || user.mobileNumber.isEmpty)
            ? splitFullMobileNumber(user.fullMobileNumber)
            : (countryCode: user.countryCode, mobileNumber: user.mobileNumber);
        final userToPersist = user.copyWith(
          password: passcode,
          countryCode: user.countryCode.isEmpty ? parts.countryCode : user.countryCode,
          mobileNumber: user.mobileNumber.isEmpty ? parts.mobileNumber : user.mobileNumber,
        );
        _state = state.copyWith(
          authStatus: AuthStatus.authorized,
          user: userToPersist,
          isLoading: false,
          errorMessage: null,
        );

        await StorageService.setString(AppConstants.tokenKey, accessToken);
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await StorageService.setString('refresh_token', refreshToken);
        }
        await StorageService.setString(
          AppConstants.userKey,
          jsonEncode(userToPersist.toJson()),
        );

        notifyListeners();
        onUnlockCallback?.call();
        // Refresh account details in background to sync latest profile data
        fetchAccountDetails();
        // Register FCM push-notification device token with backend (fire-and-forget).
        unawaited(PushNotificationService.instance.registerCurrentDevice());
        return true;
      }

      final l10n = appLocalizationsFromStoredLocale();
      final errorMsg = _localizedMessageFromRawResponse(
        rawResponse,
        fallback: l10n.loginFailed,
      );
      _state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      notifyListeners();
      return false;
    } catch (e) {
      _state = state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  /// Silent re-login via `/v1/auth/login/passcode` — the OTP-less variant
  /// used after server-side session revocation (change passcode, disable 2FA,
  /// change phone) and after registration. Returns true on success and
  /// updates `_state` + tokens like [login] does.
  Future<bool> loginWithPasscode({
    required String mobileNumber,
    required String countryCode,
    required String passcode,
  }) async {
    try {
      _state = state.copyWith(isLoading: true, errorMessage: null);
      notifyListeners();

      final normalizedPhone = mobileNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final normalizedCountry = countryCode.trim();

      final rawResponse = await AuthService.loginPasscode(
        countryCode: normalizedCountry,
        mobileNumber: normalizedPhone,
        passcode: passcode,
      );

      final int? statusCode = rawResponse['statusCode'] as int?;
      final bool isSuccess =
          (statusCode != null && statusCode >= 200 && statusCode < 300) ||
          rawResponse['status']?.toString() == 'success';
      final Map<String, dynamic>? data =
          rawResponse['data'] is Map<String, dynamic>
          ? rawResponse['data'] as Map<String, dynamic>
          : null;
      final String? accessToken = data?['access_token']?.toString();
      final String? refreshToken = data?['refresh_token']?.toString();
      final dynamic userData = data?['user'];
      final Map<String, dynamic>? userJson = userData is Map<String, dynamic>
          ? userData
          : null;
      final UserModel? user = userJson != null
          ? UserModel.fromJson(userJson)
          : null;

      if (isSuccess &&
          user != null &&
          accessToken != null &&
          accessToken.isNotEmpty) {
        // Persist the entered passcode + the entered phone/country so flows
        // like change-phone or disable-2FA can hard-login again later (the
        // API user payload may omit these fields). If even those aren't
        // available, derive from the full mobile number as a last resort.
        final fallbackParts =
            splitFullMobileNumber(user.fullMobileNumber);
        final resolvedCountry = normalizedCountry.isNotEmpty
            ? normalizedCountry
            : (user.countryCode.isNotEmpty
                ? user.countryCode
                : fallbackParts.countryCode);
        final resolvedPhone = normalizedPhone.isNotEmpty
            ? normalizedPhone
            : (user.mobileNumber.isNotEmpty
                ? user.mobileNumber
                : fallbackParts.mobileNumber);
        final userToPersist = user.copyWith(
          password: passcode,
          countryCode: resolvedCountry,
          mobileNumber: resolvedPhone,
        );
        _state = state.copyWith(
          authStatus: AuthStatus.authorized,
          user: userToPersist,
          isLoading: false,
          errorMessage: null,
        );

        await StorageService.setString(AppConstants.tokenKey, accessToken);
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await StorageService.setString('refresh_token', refreshToken);
        }
        await StorageService.setString(
          AppConstants.userKey,
          jsonEncode(userToPersist.toJson()),
        );

        notifyListeners();
        onUnlockCallback?.call();
        // Refresh account details in background to sync latest profile data.
        fetchAccountDetails();
        // Register FCM push-notification device token with backend (fire-and-forget).
        unawaited(PushNotificationService.instance.registerCurrentDevice());
        return true;
      }

      final l10n = appLocalizationsFromStoredLocale();
      final errorMsg = _localizedMessageFromRawResponse(
        rawResponse,
        fallback: l10n.loginFailed,
      );
      _state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      notifyListeners();
      return false;
    } catch (e) {
      _state = state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> softLogin(String passcode) async {
    try {
      _state = state.copyWith(isLoading: true, errorMessage: null);
      notifyListeners();

      final rawResponse = await AuthService.softLogin(passcode: passcode);
      final int? statusCode = rawResponse['statusCode'] as int?;
      final dynamic data = rawResponse['data'];
      final String? userId = data is Map<String, dynamic>
          ? data['user_id']?.toString()
          : null;
      final bool isSuccess =
          statusCode == 200 && userId != null && userId.isNotEmpty;

      if (isSuccess) {
        final currentUser = _state.user;
        if (currentUser != null) {
          final updated = currentUser.copyWith(password: passcode);
          _state = state.copyWith(
            user: updated,
            isLoading: false,
            errorMessage: null,
          );
          await StorageService.setString(
            AppConstants.userKey,
            jsonEncode(updated.toJson()),
          );
        } else {
          _state = state.copyWith(isLoading: false, errorMessage: null);
        }
        notifyListeners();
        onUnlockCallback?.call();
        // Refresh account details in background to sync latest profile data
        fetchAccountDetails();
        return true;
      }

      final l10n = appLocalizationsFromStoredLocale();
      final errorMsg = _localizedMessageFromRawResponse(
        rawResponse,
        fallback: l10n.softLoginFailed,
      );
      _state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      notifyListeners();
      return false;
    } catch (e) {
      _state = state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  /// Schedules deletion of the signed-in user's account. The backend grants a
  /// 7-day grace period during which the user can cancel by logging in again.
  /// Returns the localized success message from the API. The caller is
  /// responsible for signing the user out and navigating away.
  Future<String> requestAccountDeletion() async {
    try {
      final currentUser = _state.user;
      if (currentUser == null || !_state.isAuthenticated) {
        throw Exception(appLocalizationsFromStoredLocale().somethingWentWrong);
      }

      _state = _state.copyWith(isLoading: true, errorMessage: null);
      notifyListeners();

      final response = await AuthService.requestAccountDeletion();
      final l10n = appLocalizationsFromStoredLocale();

      if (!_isApiSuccess(response)) {
        final errorMsg = _localizedMessageFromRawResponse(
          response,
          fallback: l10n.somethingWentWrong,
        );
        _state = _state.copyWith(isLoading: false, errorMessage: errorMsg);
        notifyListeners();
        throw Exception(errorMsg);
      }

      final successMessage = _localizedMessageFromRawResponse(
        response,
        fallback: l10n.deleteAccountScheduled,
      );

      _state = _state.copyWith(isLoading: false, errorMessage: null);
      notifyListeners();
      return successMessage;
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    // Tell the server to revoke this session and unregister the FCM token.
    // Best-effort: we still clear local state below even if the call fails
    // (offline, already-revoked session, etc.) so the user is always signed
    // out client-side.
    try {
      final deviceToken =
          await PushNotificationService.instance.currentDeviceToken();
      await AuthService.logout(deviceToken: deviceToken);
    } catch (_) {
      // Ignore — local sign-out must still proceed.
    }

    await StorageService.remove(AppConstants.userKey);
    await StorageService.remove(AppConstants.tokenKey);
    await StorageService.remove('refresh_token');
    // Drop the device-global biometric preference so it can't leak to the next
    // account signing in on this device. BiometricProvider.onAuthChanged
    // re-syncs its in-memory flag off the back of the notify below.
    await StorageService.remove(AppConstants.biometricEnabledKey);
    _state = const AuthState(authStatus: AuthStatus.unauthorized);
    notifyListeners();
  }

  /// Clears only auth tokens (not user data) so the session can be refreshed
  /// via [login] without losing stored credentials. Used by flows like
  /// disable-2FA and change-passcode where the backend revokes the session.
  Future<void> _clearSessionTokens() async {
    await StorageService.remove(AppConstants.tokenKey);
    await StorageService.remove('refresh_token');
  }

  /// Returns whether [passcode] matches the stored passcode for the signed-in user
  /// (including mock override map), without mutating auth state.
  Future<bool> verifyStoredPasscodeForCurrentUser(String passcode) async {
    try {
      final user = state.user;
      if (user == null || !state.isAuthenticated) {
        return false;
      }
      final normalizedPhone = user.mobileNumber.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      final normalizedCountry = user.countryCode.trim();
      final overrideKey = '$normalizedCountry$normalizedPhone';
      final effectivePasscode =
          MockData.passcodeOverrides[overrideKey] ?? user.password;
      return passcode == effectivePasscode;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setPasscode(
    String phoneNumber,
    String countryCode,
    String newPasscode,
  ) async {
    try {
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final normalizedCountry = countryCode.trim();
      final overrideKey = '$normalizedCountry$normalizedPhone';

      final userExists = MockData.dummyUsers.any(
        (u) =>
            u.mobileNumber == normalizedPhone &&
            u.countryCode == normalizedCountry,
      );
      if (!userExists) return false;

      MockData.passcodeOverrides[overrideKey] = newPasscode;

      final user = MockData.dummyUsers.firstWhere(
        (u) =>
            u.mobileNumber == normalizedPhone &&
            u.countryCode == normalizedCountry,
      );
      final updatedUser = user.copyWith(password: newPasscode);

      _state = state.copyWith(
        authStatus: AuthStatus.authorized,
        user: updatedUser,
      );
      await StorageService.setString(
        AppConstants.userKey,
        jsonEncode(updatedUser.toJson()),
      );
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setRegistrationPasscode({
    required String registrationToken,
    required String passcode,
    required String confirmPasscode,
  }) async {
    try {
      _state = state.copyWith(isLoading: true, errorMessage: null);
      notifyListeners();

      final response = await AuthService.setRegistrationPasscode(
        registrationToken: registrationToken,
        passcode: passcode,
        confirmPasscode: confirmPasscode,
      );

      if (_isApiSuccess(response)) {
        _state = state.copyWith(isLoading: false, errorMessage: null);
        notifyListeners();
        return true;
      } else {
        final l10n = appLocalizationsFromStoredLocale();
        final errorMsg = _localizedMessageFromRawResponse(
          response,
          fallback: l10n.registrationFailed,
        );
        _state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _state = state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> resetForgotPasscodeAndLogin({
    required String phoneNumber,
    required String countryCode,
    required String resetToken,
    required String newPasscode,
    required String confirmPasscode,
  }) async {
    try {
      _state = state.copyWith(isLoading: true, errorMessage: null);
      notifyListeners();

      await ForgotPasscodeService.resetPasscode(
        resetToken: resetToken,
        newPasscode: newPasscode,
        confirmPasscode: confirmPasscode,
      );

      // After server-side reset, silent re-login with the new passcode.
      final loggedIn = await loginWithPasscode(
        mobileNumber: phoneNumber,
        countryCode: countryCode,
        passcode: newPasscode,
      );
      return loggedIn;
    } catch (e) {
      _state = state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  Future<void> verifyUser() async {
    final currentUser = _state.user;
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(isVerified: true);

      // Update local state
      _state = state.copyWith(user: updatedUser);

      // Update storage
      await StorageService.setString(
        AppConstants.userKey,
        jsonEncode(updatedUser.toJson()),
      );

      notifyListeners();
    }
  }

  /// Fetches account details from the backend and updates the local user's
  /// [isVerified] status. Fails silently on error.
  Future<void> fetchAccountDetails() async {
    try {
      final currentUser = _state.user;
      if (currentUser == null || !_state.isAuthenticated) return;

      final response = await AuthService.fetchAccountDetails();
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        final isVerified = data['isVerified'];
        final email = data['email']?.toString();
        final phone = data['phone']?.toString();

        var updatedUser = currentUser;
        if (isVerified is bool) {
          updatedUser = updatedUser.copyWith(isVerified: isVerified);
        }
        if (email != null && email.isNotEmpty) {
          updatedUser = updatedUser.copyWith(email: email);
        }
        if (phone != null && phone.isNotEmpty) {
          updatedUser = updatedUser.copyWith(fullMobileNumber: phone);
        }
        final twoFactorEnabled = data['twoFactorEnabled'];
        if (twoFactorEnabled is bool) {
          updatedUser = updatedUser.copyWith(
            twoFactorEnabled: twoFactorEnabled,
          );
        }
        final walletsAvailable = data['walletsAvailable'];
        if (walletsAvailable is bool) {
          updatedUser = updatedUser.copyWith(
            walletsAvailable: walletsAvailable,
          );
        }
        final walletsJson = data['wallets'];
        if (walletsJson is List && walletsJson.isNotEmpty) {
          final wallets = walletsJson
              .whereType<Map<String, dynamic>>()
              .map((e) => WalletNetworkModel.fromJson(e))
              .toList();
          updatedUser = updatedUser.copyWith(wallets: wallets);
        }

        if (updatedUser != currentUser) {
          _state = state.copyWith(user: updatedUser);
          await StorageService.setString(
            AppConstants.userKey,
            jsonEncode(updatedUser.toJson()),
          );
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('fetchAccountDetails failed: $e');
    }
  }

  /// Toggles two-factor authentication.
  /// Returns the localized success message from the API.
  /// When disabling, the backend revokes the session, so we re-login
  /// automatically using the stored phone + passcode (same as change-passcode).
  /// Throws on failure so the caller can show an error snackbar.
  Future<String> toggleTwoFactor(bool enabled) async {
    try {
      final currentUser = _state.user;
      if (currentUser == null || !_state.isAuthenticated) {
        throw Exception(appLocalizationsFromStoredLocale().somethingWentWrong);
      }

      _state = _state.copyWith(isLoading: true, errorMessage: null);
      notifyListeners();

      final response = enabled
          ? await AuthService.enableTwoFactor()
          : await AuthService.disableTwoFactor();

      final l10n = appLocalizationsFromStoredLocale();

      if (!_isApiSuccess(response)) {
        final errorMsg = _localizedMessageFromRawResponse(
          response,
          fallback: l10n.somethingWentWrong,
        );
        _state = _state.copyWith(isLoading: false, errorMessage: errorMsg);
        notifyListeners();
        throw Exception(errorMsg);
      }

      final successMessage = _localizedMessageFromRawResponse(
        response,
        fallback: enabled
            ? l10n.twoFactorAuthentication
            : l10n.twoFactorAuthentication,
      );

      if (!enabled) {
        // Session revoked on disable — clear only tokens, keep user data
        // so loginWithPasscode can use the stored credentials.
        final phone = currentUser.mobileNumber.replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );
        final country = currentUser.countryCode.trim();
        final passcode = currentUser.password;

        await _clearSessionTokens();
        final loggedIn = await loginWithPasscode(
          mobileNumber: phone,
          countryCode: country,
          passcode: passcode,
        );

        if (!loggedIn) {
          final err = _state.errorMessage ?? l10n.loginFailed;
          _state = _state.copyWith(isLoading: false);
          notifyListeners();
          throw Exception(err);
        }

        return successMessage;
      }

      // Enable succeeded — update local state and refresh from backend.
      final updatedUser = currentUser.copyWith(twoFactorEnabled: true);
      _state = _state.copyWith(
        user: updatedUser,
        isLoading: false,
        errorMessage: null,
      );
      await StorageService.setString(
        AppConstants.userKey,
        jsonEncode(updatedUser.toJson()),
      );
      notifyListeners();
      unawaited(fetchAccountDetails());
      return successMessage;
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> updateEmailForCurrentUser(String email) async {
    try {
      final user = _state.user;
      if (user == null || !_state.isAuthenticated) {
        return false;
      }
      final trimmed = email.trim();
      await WalletAddressService.saveUserEmail(user, trimmed);

      final updatedUser = user.copyWith(email: trimmed);
      _state = _state.copyWith(user: updatedUser);
      await StorageService.setString(
        AppConstants.userKey,
        jsonEncode(updatedUser.toJson()),
      );
      notifyListeners();

      // Pull authoritative profile from server to stay in sync with anything
      // the change-email flow may have updated alongside the email.
      unawaited(fetchAccountDetails());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updatePhoneForCurrentUser({
    required String countryCode,
    required String phoneNumber,
  }) async {
    try {
      final user = _state.user;
      if (user == null || !_state.isAuthenticated) {
        return false;
      }

      final oldKey =
          '${user.countryCode.trim()}'
          '${user.mobileNumber.replaceAll(RegExp(r'[^0-9]'), '')}';
      final normalizedCountry = countryCode.trim();
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final newKey = '$normalizedCountry$normalizedPhone';

      final passcodeOverride = MockData.passcodeOverrides.remove(oldKey);
      if (passcodeOverride != null) {
        MockData.passcodeOverrides[newKey] = passcodeOverride;
      }

      final updatedUser = user.copyWith(
        countryCode: normalizedCountry,
        mobileNumber: normalizedPhone,
      );
      _state = _state.copyWith(user: updatedUser);
      await StorageService.setString(
        AppConstants.userKey,
        jsonEncode(updatedUser.toJson()),
      );
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> completePhoneChangeAndRefreshSession({
    required String countryCode,
    required String phoneNumber,
  }) async {
    final user = _state.user;
    if (user == null || !_state.isAuthenticated) {
      return false;
    }

    final normalizedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final normalizedCountry = countryCode.trim();
    final passcode = user.password;

    if (passcode.length != PasscodeProvider.passcodeLength) {
      // No stored passcode — can't silent re-login. Fall back to local-only
      // phone/country update.
      return updatePhoneForCurrentUser(
        countryCode: normalizedCountry,
        phoneNumber: normalizedPhone,
      );
    }

    try {
      await _clearSessionTokens();
      return await loginWithPasscode(
        mobileNumber: normalizedPhone,
        countryCode: normalizedCountry,
        passcode: passcode,
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> validateSession() async {
    if (!state.isAuthenticated) {
      return false;
    }

    try {
      final response = await AuthService.sessionStatus();
      if (!_isApiSuccess(response)) {
        return false;
      }

      final data = response['data'];
      if (data is Map<String, dynamic>) {
        final isValid = data['is_valid'];
        if (isValid is bool) {
          return isValid;
        }

        final isRevoked = data['is_revoked'];
        if (isRevoked is bool) {
          return !isRevoked;
        }

        final status = data['status']?.toString().toLowerCase().trim();
        if (status == 'invalid' || status == 'revoked' || status == 'expired') {
          return false;
        }
      }

      return true;
    } on AppException catch (e) {
      if (e.messageKey == 'networkError') {
        return true;
      }
      return false;
    } catch (_) {
      return true;
    }
  }

  /// Updates passcode on the server, then clears local auth state so the
  /// caller can route the user back to the login screen. (The new OTP-based
  /// login flow can no longer silently re-login here.)
  Future<String> changePasscodeAndRefreshSession({
    required String currentPasscode,
    required String newPasscode,
    required String confirmPasscode,
  }) async {
    try {
      _state = state.copyWith(isLoading: true, errorMessage: null);
      notifyListeners();

      final response = await AuthService.changePasscode(
        currentPasscode: currentPasscode,
        newPasscode: newPasscode,
        confirmPasscode: confirmPasscode,
      );

      final l10n = appLocalizationsFromStoredLocale();
      if (!_isApiSuccess(response)) {
        final errorMsg = _localizedMessageFromRawResponse(
          response,
          fallback: l10n.unableToChangePasscode,
        );
        _state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        notifyListeners();
        throw Exception(errorMsg);
      }

      final successMessage = _localizedMessageFromRawResponse(
        response,
        fallback: l10n.passcodeChangedSuccessfully,
      );

      // Server revokes the old session; restore silently with the new passcode.
      final currentUser = _state.user;
      if (currentUser == null) {
        // Unexpected — state shouldn't lose user mid-flow. Bail out cleanly.
        _state = state.copyWith(isLoading: false, errorMessage: null);
        notifyListeners();
        return successMessage;
      }
      final phone = currentUser.mobileNumber.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      final country = currentUser.countryCode.trim();

      await _clearSessionTokens();
      final loggedIn = await loginWithPasscode(
        mobileNumber: phone,
        countryCode: country,
        passcode: newPasscode,
      );

      if (!loggedIn) {
        final err = _state.errorMessage ?? l10n.loginFailed;
        _state = state.copyWith(isLoading: false);
        notifyListeners();
        throw Exception(err);
      }

      _state = state.copyWith(isLoading: false, errorMessage: null);
      notifyListeners();
      return successMessage;
    } catch (e) {
      _state = state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
      rethrow;
    }
  }
}
