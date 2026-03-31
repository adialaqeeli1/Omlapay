import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../core/constants/constants.dart';
import '../core/l10n/app_localizations_from_storage.dart';
import '../core/models/auth_state/auth_state.dart';
import '../core/models/user_model/user_model.dart';
import '../core/mock_data/mock_data.dart';
import '../core/services/storage_helper.dart';
import '../core/utils/app_exception.dart';
import '../core/utils/api_message_helper.dart';
import '../modules/auth/providers/passcode_provider.dart';
import '../modules/auth/services/auth_service.dart';
import '../modules/auth/services/forgot_passcode_service.dart';
import '../modules/settings/services/wallet_address_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthState _state = const AuthState();
  AuthState get state => _state;

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

  Future<bool> login(
    String mobileNumber,
    String countryCode,
    String password,
  ) async {
    try {
      _state = state.copyWith(isLoading: true, errorMessage: null);
      notifyListeners();

      final normalizedPhone = mobileNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final normalizedCountry = countryCode.trim();

      final rawResponse = await AuthService.login(
        countryCode: normalizedCountry,
        mobileNumber: normalizedPhone,
        passcode: password,
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
        // Keep the entered passcode locally so flows like change-phone can
        // hard-login again with the new number (API user may omit `password`).
        final userToPersist = user.copyWith(password: password);
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

  Future<void> logout() async {
    await StorageService.remove(AppConstants.userKey);
    await StorageService.remove(AppConstants.tokenKey);
    await StorageService.remove('refresh_token');
    _state = const AuthState(authStatus: AuthStatus.unauthorized);
    notifyListeners();
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

      final loggedIn = await login(phoneNumber, countryCode, newPasscode);
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

  Future<bool> updateEmailForCurrentUser(String email) async {
    try {
      final user = _state.user;
      if (user == null || !_state.isAuthenticated) {
        return false;
      }
      await WalletAddressService.saveUserEmail(user, email);
      notifyListeners();
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

  /// After change-phone succeeds on the server, clears the old session and performs
  /// hard login with the **new** number and the passcode from the last successful
  /// login (stored on [UserModel.password]). If no passcode is stored locally,
  /// falls back to [updatePhoneForCurrentUser] only.
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
      return updatePhoneForCurrentUser(
        countryCode: normalizedCountry,
        phoneNumber: normalizedPhone,
      );
    }

    try {
      await logout();
      return await login(normalizedPhone, normalizedCountry, passcode);
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

  /// Updates passcode on the server, then [logout] and hard [login] with the
  /// same phone and **new** passcode so tokens and cached [UserModel] stay in sync.
  Future<String> changePasscodeAndRefreshSession({
    required String currentPasscode,
    required String newPasscode,
    required String confirmPasscode,
    required String countryCode,
    required String mobileNumber,
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

      final normalizedPhone =
          mobileNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final normalizedCountry = countryCode.trim();

      await logout();
      final loggedIn = await login(
        normalizedPhone,
        normalizedCountry,
        newPasscode,
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
