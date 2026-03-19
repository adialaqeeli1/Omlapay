import 'dart:io';

import 'package:dio/dio.dart';

import '../constants/constants.dart';
import '../constants/endpoints.dart';
import '../network/network_client.dart';
import '../utils/app_exception.dart';
import 'storage_helper.dart';

class ApiHelper {
  static String? get _token => StorageService.getString(AppConstants.tokenKey);

  static NetworkClient _getClient() {
    return NetworkClient(
      baseUrl: Endpoints.baseUrl,
      token: _token != null ? NetworkToken(access: _token) : null,
    );
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final client = _getClient();
      final response = await client.get(url: endpoint);
      return _handleNetworkResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } on SocketException {
      throw AppException('Network error', messageKey: 'networkError');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Network error: $e', messageKey: 'unknownError');
    }
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final client = _getClient();
      final response = await client.post(url: endpoint, data: body);
      return _handleNetworkResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } on SocketException {
      throw AppException('Network error', messageKey: 'networkError');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Network error: $e', messageKey: 'unknownError');
    }
  }

  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final client = _getClient();
      final response = await client.put(url: endpoint, data: body);
      return _handleNetworkResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } on SocketException {
      throw AppException('Network error', messageKey: 'networkError');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Network error: $e', messageKey: 'unknownError');
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final client = _getClient();
      final response = await client.delete(url: endpoint);
      return _handleNetworkResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } on SocketException {
      throw AppException('Network error', messageKey: 'networkError');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Network error: $e', messageKey: 'unknownError');
    }
  }

  static Map<String, dynamic> _handleNetworkResponse(
    NetworkDataRespone response,
  ) {
    if (response.isSuccess) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {};
    } else {
      final error = response.error;
      String message = 'Request failed with status ${response.statusCode}';
      if (error is Map<String, dynamic>) {
        message = error['message'] as String? ?? message;
      }
      throw AppException(message, messageKey: 'requestFailed');
    }
  }

  static AppException _handleDioException(DioException error) {
    String message = 'Network error: ${error.message}';
    String messageKey = 'unknownError';

    if (error.response?.data != null) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        message = data['message'] as String? ?? message;
      }
      messageKey = 'requestFailed';
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      message = 'Network connection error';
      messageKey = 'networkError';
    }

    return AppException(message, messageKey: messageKey);
  }
}
