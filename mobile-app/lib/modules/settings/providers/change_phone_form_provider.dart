import 'package:flutter/foundation.dart';

class ChangePhoneFormProvider extends ChangeNotifier {
  ChangePhoneFormProvider({this.countryCode = '+966'});

  final String countryCode;
  String _phone = '';
  bool _submitted = false;

  String get phone => _phone;
  bool get isSubmitted => _submitted;
  String get digitsOnly => _phone.replaceAll(RegExp(r'[^0-9]'), '');
  bool get isValidPhone => digitsOnly.length == 9;
  bool get canContinue => isValidPhone;

  void onPhoneChanged(String value) {
    if (_phone == value) return;
    _phone = value;
    notifyListeners();
  }

  void markSubmitted() {
    _submitted = true;
    notifyListeners();
  }
}
