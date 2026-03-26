import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:dio/dio.dart';

part './network_token.dart';
part './network_interceptor.dart';
part './network_data_response.dart';

class NetworkClient {
  NetworkClient({
    this.baseUrl,
    this.token,
    this.onTokenExpired,
    this.defaultConnectTimeout = const Duration(milliseconds: 100000),
    this.defaultReceiveTimeout = const Duration(milliseconds: 100000),
    this.globalHeaders,
  });

  final String? baseUrl;
  final NetworkToken? token;
  final OnTokenExpiredCallback? onTokenExpired;
  final Duration defaultConnectTimeout;
  final Duration defaultReceiveTimeout;
  final Map<String, dynamic>? globalHeaders;

  NetworkClient copyWith({
    String? baseUrl,
    NetworkToken? token,
    OnTokenExpiredCallback? onTokenExpired,
    Duration? defaultConnectTimeout,
    Duration? defaultReceiveTimeout,
    Map<String, dynamic>? globalHeaders,
  }) => NetworkClient(
    baseUrl: baseUrl ?? this.baseUrl,
    token: token ?? this.token,
    onTokenExpired: onTokenExpired ?? this.onTokenExpired,
    defaultConnectTimeout: defaultConnectTimeout ?? this.defaultConnectTimeout,
    defaultReceiveTimeout: defaultReceiveTimeout ?? this.defaultReceiveTimeout,
    globalHeaders: globalHeaders ?? this.globalHeaders,
  );

  Dio get _client {
    final Dio dio = Dio();

    if (baseUrl != null) {
      dio
        ..options = BaseOptions(
          baseUrl: baseUrl!,
          connectTimeout: defaultConnectTimeout,
          receiveTimeout: defaultReceiveTimeout,
          responseType: ResponseType.json,
        )
        ..httpClientAdapter
        ..interceptors.addAll([
          // CookieManager(cookieJar),
          _LoggingInterceptor(
            tokenInstance: token,
            onTokenExpired: onTokenExpired,
            globalHeaders: globalHeaders,
          ),
        ]);
    }
    return dio;
  }

  Future<NetworkDataRespone> get({
    required String url,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response<dynamic> response = await _client.get(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      NetworkDataRespone responseData = NetworkDataRespone.empty();

      if (response.statusCode != null) {
        responseData.statusCode = response.statusCode!;
        final bool isSuccess =
            response.statusCode! >= 200 && response.statusCode! < 400;
        responseData.isSuccess = isSuccess;

        if (isSuccess) {
          responseData.data = response.data;
        } else {
          responseData.error = response.data;
        }
      }

      return responseData;
    } on FormatException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<NetworkDataRespone> post({
    required String url,
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response<dynamic> response = await _client.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      NetworkDataRespone responseData = NetworkDataRespone.empty();

      if (response.statusCode != null) {
        responseData.statusCode = response.statusCode!;
        final bool isSuccess =
            response.statusCode! >= 200 && response.statusCode! < 400;
        responseData.isSuccess = isSuccess;

        if (isSuccess) {
          responseData.data = response.data;
        } else {
          responseData.error = response.data;
        }
      }

      return responseData;
    } on FormatException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<NetworkDataRespone> put({
    required String url,
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response<dynamic> response = await _client.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      NetworkDataRespone responseData = NetworkDataRespone.empty();

      if (response.statusCode != null) {
        responseData.statusCode = response.statusCode!;
        final bool isSuccess =
            response.statusCode! >= 200 && response.statusCode! < 400;
        responseData.isSuccess = isSuccess;

        if (isSuccess) {
          responseData.data = response.data;
        } else {
          responseData.error = response.data;
        }
      }

      return responseData;
    } on FormatException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<NetworkDataRespone> delete({
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      Response<dynamic> response = await _client.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      NetworkDataRespone responseData = NetworkDataRespone.empty();

      if (response.statusCode != null) {
        responseData.statusCode = response.statusCode!;
        final bool isSuccess =
            response.statusCode! >= 200 && response.statusCode! < 400;
        responseData.isSuccess = isSuccess;

        if (isSuccess) {
          responseData.data = response.data;
        } else {
          responseData.error = response.data;
        }
      }

      return responseData;
    } on FormatException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<NetworkDataRespone> patch({
    required String url,
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response<dynamic> response = await _client.patch(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      NetworkDataRespone responseData = NetworkDataRespone.empty();

      if (response.statusCode != null) {
        responseData.statusCode = response.statusCode!;
        final bool isSuccess =
            response.statusCode! >= 200 && response.statusCode! < 400;
        responseData.isSuccess = isSuccess;

        if (isSuccess) {
          responseData.data = response.data;
        } else {
          responseData.error = response.data;
        }
      }

      return responseData;
    } on FormatException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<NetworkDataRespone> multipartPost({
    required String url,
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response<dynamic> response = await _client.post(
        url,
        data: FormData.fromMap(data, ListFormat.multiCompatible),
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      NetworkDataRespone responseData = NetworkDataRespone.empty();

      if (response.statusCode != null) {
        responseData.statusCode = response.statusCode!;
        final bool isSuccess =
            response.statusCode! >= 200 && response.statusCode! < 400;
        responseData.isSuccess = isSuccess;

        if (isSuccess) {
          responseData.data = response.data;
        } else {
          responseData.error = response.data;
        }
      }

      return responseData;
    } on FormatException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<NetworkDataRespone> multipartPut({
    required String url,
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response<dynamic> response = await _client.put(
        url,
        data: FormData.fromMap(data),
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      NetworkDataRespone responseData = NetworkDataRespone.empty();

      if (response.statusCode != null) {
        responseData.statusCode = response.statusCode!;
        final bool isSuccess =
            response.statusCode! >= 200 && response.statusCode! < 400;
        responseData.isSuccess = isSuccess;

        if (isSuccess) {
          responseData.data = response.data;
        } else {
          responseData.error = response.data;
        }
      }

      return responseData;
    } on FormatException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<String?> download(
    String url,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    dynamic data,
    Options? options,
  }) async {
    try {
      final Response response = await _client.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        data: data,
        options: options,
      );

      if (response.statusCode == 200) {
        return savePath;
      } else {
        throw Exception('Unable to download the file');
      }
    } on FormatException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}
