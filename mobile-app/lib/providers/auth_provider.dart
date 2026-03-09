import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../core/constants/constants.dart';
import '../core/services/storage_helper.dart';
import '../core/models/user_model/user_model.dart';
import '../core/models/auth_state/auth_state.dart';
import '../modules/auth/services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthState _state = const AuthState();
  AuthState get state => _state;

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

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Find user verification
      final user = UserService.findUserByPhone(mobileNumber, countryCode);

      if (user != null && user.password == password) {
        // Persist user session
        await StorageService.setString(
          AppConstants.userKey,
          jsonEncode(user.toJson()),
        );

        // Simulate saving a token
        await StorageService.setString(
          AppConstants.tokenKey,
          'dummy_jwt_token',
        );

        _state = state.copyWith(
          isLoading: false,
          authStatus: AuthStatus.authorized,
          user: user,
        );
        notifyListeners();
        return true;
      } else {
        _state = state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid credentials',
          authStatus: AuthStatus.unauthorized,
        );
        notifyListeners();
        return false;
      }
    } catch (e) {
      _state = state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.remove(AppConstants.userKey);
    await StorageService.remove(AppConstants.tokenKey);
    _state = const AuthState(authStatus: AuthStatus.unauthorized);
    notifyListeners();
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
}
