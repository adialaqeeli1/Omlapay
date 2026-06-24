import 'package:dio/dio.dart';

import '../../../core/constants/endpoints.dart';
import '../../../core/services/api_helper.dart';
import '../../../core/utils/app_exception.dart';
import '../models/support_request_model.dart';
import '../models/support_request_detail_model.dart';

class HelpCenterService {
  /// Fetches the support request list.
  ///
  /// When [macAddress] is provided, hits the guest endpoint
  /// (`/v1/guest/support-requests`) and scopes the list to that device.
  /// When `null`, hits the authenticated endpoint and relies on the user
  /// from the bearer token.
  Future<SupportRequestsResponse> fetchSupportRequests({
    String? status,
    int page = 1,
    int limit = 10,
    String? macAddress,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null) {
      queryParams['status'] = status;
    }
    if (macAddress != null && macAddress.isNotEmpty) {
      queryParams['macAddress'] = macAddress;
    }

    final endpoint = macAddress != null && macAddress.isNotEmpty
        ? Endpoints.guestSupportRequests
        : Endpoints.supportRequests;

    final response = await ApiHelper.get(
      endpoint,
      queryParameters: queryParams,
    );

    final dynamic data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw AppException(
        'Invalid support requests response',
        messageKey: 'requestFailed',
      );
    }

    return SupportRequestsResponse.fromJson(data);
  }

  Future<String> uploadFile({
    required String filePath,
    required String fileName,
  }) async {
    final response = await ApiHelper.multipartPost(
      Endpoints.upload,
      data: {
        'files': await MultipartFile.fromFile(filePath, filename: fileName),
      },
      queryParameters: {'prefix': 'support-requests'},
    );

    final dynamic data = response['data'];
    if (data is Map<String, dynamic>) {
      final attachmentUrl = data['attachmentUrl'] as String?;
      if (attachmentUrl != null && attachmentUrl.isNotEmpty) {
        return attachmentUrl;
      }
    }

    throw AppException('Failed to upload file', messageKey: 'requestFailed');
  }

  /// Creates a support request.
  ///
  /// When [macAddress] is provided, hits the guest endpoint and includes
  /// `macAddress` in the body. Otherwise hits the authenticated endpoint.
  /// Guests cannot attach files, so [attachmentUrl] should be `null` in
  /// that case (callers are responsible).
  Future<void> submitRequest({
    required String title,
    required String description,
    String? attachmentUrl,
    String? macAddress,
  }) async {
    final body = <String, dynamic>{'title': title, 'description': description};
    if (attachmentUrl != null) {
      body['attachmentUrl'] = attachmentUrl;
    }
    if (macAddress != null && macAddress.isNotEmpty) {
      body['macAddress'] = macAddress;
      await ApiHelper.post(Endpoints.guestSupportRequests, body);
    } else {
      await ApiHelper.post(Endpoints.supportRequests, body);
    }
  }

  /// Fetches a single support request.
  ///
  /// When [macAddress] is provided, hits the guest endpoint with
  /// `macAddress` as a query param so the backend can scope ownership.
  Future<SupportRequestDetailModel> fetchRequestDetail(
    String requestId, {
    String? macAddress,
  }) async {
    final isGuest = macAddress != null && macAddress.isNotEmpty;
    final response = await ApiHelper.get(
      isGuest
          ? Endpoints.guestSupportRequestDetail(requestId)
          : Endpoints.supportRequestDetail(requestId),
      queryParameters: isGuest ? {'macAddress': macAddress} : null,
    );

    final dynamic data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw AppException(
        'Invalid request detail response',
        messageKey: 'requestFailed',
      );
    }

    final request = data['request'];
    if (request is! Map<String, dynamic>) {
      throw AppException(
        'Invalid request detail response',
        messageKey: 'requestFailed',
      );
    }

    return SupportRequestDetailModel.fromJson(request);
  }

  /// Re-opens a resolved/rejected support request.
  ///
  /// Mirrors the create payload: the user's [description] is required and an
  /// optional [attachmentUrl] (from [uploadFile]) can be included.
  Future<void> reopenRequest(
    String requestId, {
    required String description,
    String? attachmentUrl,
  }) async {
    final body = <String, dynamic>{'description': description};
    if (attachmentUrl != null) {
      body['attachmentUrl'] = attachmentUrl;
    }
    await ApiHelper.post(Endpoints.supportRequestReopen(requestId), body);
  }
}
