import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_idensic_mobile_sdk_plugin/flutter_idensic_mobile_sdk_plugin.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../core/utils/api_message_helper.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/kyc_status_provider.dart';
import '../services/kyc_verification_service.dart';

class KycVerificationProvider extends ChangeNotifier {
  bool _isSubmitting = false;

  bool get isSubmitting => _isSubmitting;

  /// Validates form and returns collected data, or null if invalid.
  ({
    String firstName,
    String lastName,
    String residentialCountry,
    String documentCountry,
    String city,
    String address,
    String dob,
  })? validateForm(FormGroup form) {
    form.markAllAsTouched();
    if (!form.valid) return null;

    final firstName =
        (form.control('firstName').value ?? '').toString().trim();
    final lastName =
        (form.control('lastName').value ?? '').toString().trim();
    final residentialCountry =
        (form.control('residentialCountry').value ?? '')
            .toString()
            .trim()
            .toUpperCase();
    final documentCountry =
        (form.control('documentCountry').value ?? '')
            .toString()
            .trim()
            .toUpperCase();
    final city = (form.control('city').value ?? '').toString().trim();
    final address = (form.control('address').value ?? '').toString().trim();
    final dob = _toIsoDate(
      (form.control('dateOfBirth').value ?? '').toString(),
    );

    return (
      firstName: firstName,
      lastName: lastName,
      residentialCountry: residentialCountry,
      documentCountry: documentCountry,
      city: city,
      address: address,
      dob: dob,
    );
  }

  Future<({String message, bool shouldNavigateBack})> launchSumSub({
    required String firstName,
    required String lastName,
    required String residentialCountry,
    required String documentCountry,
    required String city,
    required String address,
    required String dob,
    required Locale locale,
    required String startFailedFallback,
    required String successFallback,
    required AuthProvider authProvider,
    required KycStatusProvider kycStatusProvider,
  }) async {
    if (_isSubmitting) {
      return (message: '', shouldNavigateBack: false);
    }

    _isSubmitting = true;
    notifyListeners();

    try {
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
        'KycVerificationProvider.launchSumSub request: ${jsonEncode(requestPayload)}',
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

      final shouldBack =
          result.status == SNSMobileSDKStatus.Approved ||
          result.status == SNSMobileSDKStatus.FinallyRejected ||
          result.status == SNSMobileSDKStatus.Failed;

      if (result.status == SNSMobileSDKStatus.Approved) {
        try {
          debugPrint('Sumsub approved — starting Binance KYC');
          await KycVerificationService.startBinanceKyc();
          debugPrint('Binance KYC started — refreshing account details');
          await authProvider.fetchAccountDetails();
          await kycStatusProvider.fetchKycStatus();
        } catch (e) {
          debugPrint('Post-approval flow error: $e');
        }
      }

      final message = ApiMessageHelper.localizedFromResponse(
        response.raw,
        fallback: successFallback,
      );

      return (message: message, shouldNavigateBack: shouldBack);
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
