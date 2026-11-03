part of './network_client.dart';

typedef OnTokenExpiredCallback =
    Future<NetworkToken?> Function(NetworkToken oldTokens);

class _LoggingInterceptor extends Interceptor {
  _LoggingInterceptor({
    this.tokenInstance,
    this.onTokenExpired,
    this.globalHeaders,
  });

  final NetworkToken? tokenInstance;
  final OnTokenExpiredCallback? onTokenExpired;
  final Map<String, dynamic>? globalHeaders;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final defaultHeaders = {
      ...options.headers,
      if (globalHeaders != null) ...globalHeaders!,
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    if (tokenInstance != null) {
      if (onTokenExpired != null) {
        debugPrint('Token expired => ${tokenInstance!.isAccessTokenExpired}');
        if (tokenInstance!.isAccessTokenExpired) {
          debugPrint('Refreshing expired token...');
          defaultHeaders['Authorization'] = await onTokenExpired
              ?.call(tokenInstance!)
              .then(
                (NetworkToken? updatedToken) =>
                    updatedToken?.token ?? tokenInstance!.token,
              );
        } else {
          defaultHeaders['Authorization'] = tokenInstance!.token;
        }
      } else {
        defaultHeaders['Authorization'] = tokenInstance!.token;
      }
    }

    options.headers = defaultHeaders;

    if (kDebugMode) {
      dynamic dataToLog = options.data;
      if (options.data is FormData) {
        final data = {};
        for (MapEntry<String, String> element
            in (options.data as FormData).fields) {
          data.addEntries([element]);
        }
        for (var element in (options.data as FormData).files) {
          data[element.key] =
              (element.value).filename ?? element.value.toString();
        }
        dataToLog = data;
      }
      
      String headersStr;
      try { headersStr = const JsonEncoder.withIndent('  ').convert(options.headers); } catch (_) { headersStr = options.headers.toString(); }
      
      String bodyStr;
      try { bodyStr = dataToLog != null ? const JsonEncoder.withIndent('  ').convert(dataToLog) : 'null'; } catch (_) { bodyStr = dataToLog.toString(); }

      developer.log(
        '\n================ REQUEST =================\n'
        'URL: ${options.uri}\n'
        'Method: ${options.method}\n'
        'Headers: $headersStr\n'
        'Body: $bodyStr\n'
        '==========================================',
        name: 'API_REQUEST',
      );
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      String dataStr = 'null';
      if (err.response?.data != null) {
        try { dataStr = const JsonEncoder.withIndent('  ').convert(err.response?.data); } catch (_) { dataStr = err.response!.data.toString(); }
      }
      developer.log(
        '\n================ ERROR ===================\n'
        'URL: ${err.requestOptions.uri}\n'
        'Status Code: ${err.response?.statusCode}\n'
        'Message: ${err.message}\n'
        'Response Data: $dataStr\n'
        '==========================================',
        name: 'API_ERROR',
        error: err,
      );
    }
    switch (err.type) {
      case DioExceptionType.cancel:
        break;
      case DioExceptionType.connectionTimeout:
        break;
      case DioExceptionType.unknown:
        break;
      case DioExceptionType.receiveTimeout:
        break;
      case DioExceptionType.badResponse:
        return handler.resolve(err.response!);
      case DioExceptionType.badCertificate:
        break;
      case DioExceptionType.connectionError:
        break;
      case DioExceptionType.sendTimeout:
        break;
    }
    return handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      String dataStr;
      try { dataStr = response.data != null ? const JsonEncoder.withIndent('  ').convert(response.data) : 'null'; } catch (_) { dataStr = response.data.toString(); }
      
      developer.log(
        '\n================ RESPONSE ================\n'
        'URL: ${response.requestOptions.uri}\n'
        'Status Code: ${response.statusCode}\n'
        'Data: $dataStr\n'
        '==========================================',
        name: 'API_RESPONSE',
      );
    }
    return handler.next(response);
  }
}
