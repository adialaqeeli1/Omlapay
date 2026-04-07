import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_idensic_mobile_sdk_plugin/flutter_idensic_mobile_sdk_plugin.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../core/utils/api_message_helper.dart';
import '../services/kyc_verification_service.dart';

class KycVerificationProvider extends ChangeNotifier {
  bool _isSubmitting = false;

  bool get isSubmitting => _isSubmitting;

  Future<String> submit({
    required FormGroup form,
    required Locale locale,
    required String startFailedFallback,
    required String successFallback,
  }) async {
    if (_isSubmitting) {
      return '';
    }

    form.markAllAsTouched();
    if (!form.valid) {
      return '';
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final firstName = (form.control('firstName').value ?? '')
          .toString()
          .trim();
      final lastName = (form.control('lastName').value ?? '').toString().trim();
      final residentialCountry =
          (form.control('residentialCountry').value ?? '')
              .toString()
              .trim()
              .toUpperCase();
      final documentCountry = (form.control('documentCountry').value ?? '')
          .toString()
          .trim()
          .toUpperCase();
      final city = (form.control('city').value ?? '').toString().trim();
      final address = (form.control('address').value ?? '').toString().trim();
      final dob = _toIsoDate(
        (form.control('dateOfBirth').value ?? '').toString(),
      );

      final requestPayload = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'residentialCountry': residentialCountry,
        'dob': dob,
        'country': documentCountry,
        'city': city,
        'address': address,
      };

      debugPrint(
        'KycVerificationProvider.submit request: ${jsonEncode(requestPayload)}',
      );

      final response = await _fetchKycAccessToken(
        firstName: firstName,
        lastName: lastName,
        residentialCountry: residentialCountry,
        dob: dob,
        country: documentCountry,
        city: city,
        address: address,
      );

      final accessToken = response.token;

      if (accessToken.isEmpty) {
        throw Exception(
          ApiMessageHelper.localizedFromResponse(
            response.raw,
            fallback: startFailedFallback,
          ),
        );
      }

      Future<String> onTokenExpiration() async {
        debugPrint('KYC token expired - fetching new access token');
        final refreshed = await _fetchKycAccessToken(
          firstName: firstName,
          lastName: lastName,
          residentialCountry: residentialCountry,
          dob: dob,
          country: documentCountry,
          city: city,
          address: address,
        );
        return refreshed.token;
      }

      void onStatusChanged(
        SNSMobileSDKStatus newStatus,
        SNSMobileSDKStatus prevStatus,
      ) {
        debugPrint('Sumsub status changed: $prevStatus -> $newStatus');
      }

      void onEvent(SNSMobileSDKEvent event) {
        debugPrint('Sumsub event: $event');
      }

      final sdk = SNSMobileSDK.init(accessToken, onTokenExpiration)
          .withHandlers(onStatusChanged: onStatusChanged, onEvent: onEvent)
          .withDebug(kDebugMode)
          .withLocale(locale)
          .build();

      final result = await sdk.launch();
      debugPrint('Sumsub SDK completed with result: $result');

      return ApiMessageHelper.localizedFromResponse(
        response.raw,
        fallback: successFallback,
      );
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<({String token, Map<String, dynamic> raw})> _fetchKycAccessToken({
    required String firstName,
    required String lastName,
    required String residentialCountry,
    required String dob,
    required String country,
    required String city,
    required String address,
  }) async {
    final response = await KycVerificationService.startKyc(
      firstName: firstName,
      lastName: lastName,
      residentialCountry: residentialCountry,
      dob: dob,
      country: country,
      city: city,
      address: address,
    );
    final data = response['data'];
    final dataMap = data is Map<String, dynamic> ? data : null;
    final token = dataMap?['token']?.toString() ?? '';
    return (token: token, raw: response);
  }

  String _toIsoDate(String mmddyyyy) {
    final parts = mmddyyyy.split('/');
    if (parts.length != 3) {
      return mmddyyyy;
    }

    final month = parts[0].padLeft(2, '0');
    final day = parts[1].padLeft(2, '0');
    final year = parts[2];
    return '$year-$month-$day';
  }
}
