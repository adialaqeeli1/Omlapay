import 'dart:convert';
import 'package:collection/collection.dart';

import '../../../core/constants/constants.dart';
import '../../../core/services/storage_helper.dart';
import '../../../core/models/user_model/user_model.dart';

class UserService {
  /// Initialize dummy users data if not already present
  static Future<void> initializeDummyUsers() async {
    final existingData = StorageService.getString(AppConstants.dummyUsersKey);
    if (existingData != null) {
      // Data already exists, skip initialization
      return;
    }

    final dummyUsers = [
      UserModel(
        mobileNumber: '123456789',
        countryCode: '+966',
        password: '123456',
        firstName: 'Ahmed',
        lastName: 'Al-Saud',
      ),
      UserModel(
        mobileNumber: '502345678',
        countryCode: '+966',
        password: '234567',
        firstName: 'Fatima',
        lastName: 'Al-Rashid',
      ),
      UserModel(
        mobileNumber: '503456789',
        countryCode: '+966',
        password: '345678',
        firstName: 'Mohammed',
        lastName: 'Al-Otaibi',
      ),
      UserModel(
        mobileNumber: '504567890',
        countryCode: '+966',
        password: '456789',
        firstName: 'Sara',
        lastName: 'Al-Mutairi',
      ),
      UserModel(
        mobileNumber: '505678901',
        countryCode: '+966',
        password: '567890',
        firstName: 'Khalid',
        lastName: 'Al-Ghamdi',
      ),
    ];

    await saveUsers(dummyUsers);
  }

  /// Save list of users to local storage
  static Future<bool> saveUsers(List<UserModel> users) async {
    final usersJson = users.map((user) => user.toJson()).toList();
    return await StorageService.setString(
      AppConstants.dummyUsersKey,
      jsonEncode(usersJson),
    );
  }

  /// Get all users from local storage
  static List<UserModel> getAllUsers() {
    final data = StorageService.getString(AppConstants.dummyUsersKey);
    if (data == null) return [];

    try {
      final List<dynamic> usersJson = jsonDecode(data) as List<dynamic>;
      return usersJson
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Find user by mobile number and country code
  static UserModel? findUserByPhone(String mobileNumber, String countryCode) {
    final users = getAllUsers();
    try {
      return users.firstWhereOrNull(
        (user) =>
            user.mobileNumber == mobileNumber &&
            user.countryCode == countryCode,
      );
    } catch (e) {
      return null;
    }
  }

  /// Verify user credentials
  static bool verifyCredentials(
    String mobileNumber,
    String countryCode,
    String password,
  ) {
    final user = findUserByPhone(mobileNumber, countryCode);
    if (user == null) return false;
    return user.password == password;
  }

  /// Add a new user
  static Future<bool> addUser(UserModel user) async {
    final users = getAllUsers();
    users.add(user);
    return await saveUsers(users);
  }

  /// Clear all users data
  static Future<bool> clearUsers() async {
    return await StorageService.remove(AppConstants.dummyUsersKey);
  }
}
