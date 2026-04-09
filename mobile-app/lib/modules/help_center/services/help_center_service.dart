import 'package:dio/dio.dart';

import '../../../core/constants/endpoints.dart';
import '../../../core/services/api_helper.dart';
import '../../../core/utils/app_exception.dart';
import '../models/support_request_model.dart';

class HelpCenterService {
  Future<SupportRequestsResponse> fetchSupportRequests({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null) {
      queryParams['status'] = status;
    }

    final response = await ApiHelper.get(
      Endpoints.supportRequests,
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

    throw AppException(
      'Failed to upload file',
      messageKey: 'requestFailed',
    );
  }

  Future<void> submitRequest({
    required String title,
    required String description,
    String? attachmentUrl,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'description': description,
    };
    if (attachmentUrl != null) {
      body['attachmentUrl'] = attachmentUrl;
    }

    await ApiHelper.post(Endpoints.supportRequests, body);
  }
}
