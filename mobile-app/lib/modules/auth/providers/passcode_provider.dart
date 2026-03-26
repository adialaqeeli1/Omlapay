import 'package:flutter/material.dart';

typedef VerifyPasscodeFn =
    Future<bool> Function({
      required String phoneNumber,
      required String countryCode,
      required String passcode,
    });

class PasscodeProvider extends ChangeNotifier {
  PasscodeProvider({
    required String countryCode,
    required String phoneNumber,
  }) : _countryCode = countryCode.trim(),
       _phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

  static const int passcodeLength = 6;

  final String _countryCode;
  final String _phoneNumber;

  String _passcode = '';
  bool _hasError = false;
  bool _isVerifying = false;

  String get countryCode => _countryCode;
  String get phoneNumber => _phoneNumber;
  String get fullPhoneNumber => '$_countryCode$_phoneNumber';
  String get passcode => _passcode;
  bool get hasError => _hasError;
  bool get isVerifying => _isVerifying;
  int get enteredDigitsCount => _passcode.length;
  bool get isComplete => enteredDigitsCount == passcodeLength;

  bool get hasPhoneContext => _countryCode.isNotEmpty && _phoneNumber.isNotEmpty;
  bool get canEnterDigits => !_isVerifying;
  bool get canDeleteDigits => !_isVerifying && _passcode.isNotEmpty;

  void addDigit(String digit) {
    if (!canEnterDigits || _passcode.length >= passcodeLength) {
      return;
    }
    final sanitizedDigit = digit.replaceAll(RegExp(r'[^0-9]'), '');
    if (sanitizedDigit.isEmpty) {
      return;
    }
    _passcode = '$_passcode${sanitizedDigit[0]}';
    _hasError = false;
    notifyListeners();
  }

  void removeLastDigit() {
    if (!canDeleteDigits) {
      return;
    }
    _passcode = _passcode.substring(0, _passcode.length - 1);
    _hasError = false;
    notifyListeners();
  }

  void clearPasscode() {
    if (_passcode.isEmpty && !_hasError) {
      return;
    }
    _passcode = '';
    _hasError = false;
    notifyListeners();
  }

  Future<bool> verify({required VerifyPasscodeFn verifyPasscode}) async {
    if (!isComplete || _isVerifying) {
      return false;
    }

    _isVerifying = true;
    _hasError = false;
    notifyListeners();

    try {
      final isValid = await verifyPasscode(
        phoneNumber: phoneNumber,
        countryCode: countryCode,
        passcode: _passcode,
      );
      _hasError = !isValid;
      return isValid;
    } catch (e) {
      _hasError = true;
      rethrow;
    } finally {
      _isVerifying = false;
      notifyListeners();
    }
  }
}
