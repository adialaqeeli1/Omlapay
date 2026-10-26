import 'package:flutter/material.dart';
import '../core/constants/endpoints.dart';
import '../core/services/api_helper.dart';
import '../core/services/storage_helper.dart';
import '../core/constants/constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool _hasFetchedAppearance = false;
  bool _isAuthenticated = false;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() {
    final savedTheme = StorageService.getString(AppConstants.themeModeKey);
    if (savedTheme != null) {
      if (savedTheme == 'light') {
        _themeMode = ThemeMode.light;
      } else if (savedTheme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  void onAuthChanged(bool isAuthenticated) {
    _isAuthenticated = isAuthenticated;
    if (isAuthenticated) {
      if (!_hasFetchedAppearance) {
        _fetchAppearanceSetting();
      }
    } else {
      _hasFetchedAppearance = false;
    }
  }

  Future<void> _fetchAppearanceSetting() async {
    _hasFetchedAppearance = true;

    try {
      final response = await ApiHelper.get(Endpoints.userSettingsAppearance);
      final theme = response['data']?['theme'] as String?;
      if (theme != null) {
        final ThemeMode serverMode;
        switch (theme) {
          case 'light':
            serverMode = ThemeMode.light;
          case 'dark':
            serverMode = ThemeMode.dark;
          default:
            serverMode = ThemeMode.system;
        }
        if (_themeMode != serverMode) {
          _themeMode = serverMode;
          await StorageService.setString(AppConstants.themeModeKey, theme);
          notifyListeners();
        }
      }
    } catch (_) {
      // API failed, keep locally saved theme
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    String value = 'system';
    if (mode == ThemeMode.light) value = 'light';
    if (mode == ThemeMode.dark) value = 'dark';

    await StorageService.setString(AppConstants.themeModeKey, value);
    notifyListeners();

    if (_isAuthenticated) {
      _updateAppearanceSetting(value);
    }
  }

  Future<void> _updateAppearanceSetting(String theme) async {
    try {
      await ApiHelper.put(Endpoints.userSettingsAppearance, {'theme': theme});
    } catch (_) {
      // API failed, theme is already saved locally
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
