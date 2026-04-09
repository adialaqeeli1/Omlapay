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
}
