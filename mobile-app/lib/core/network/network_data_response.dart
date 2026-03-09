part of 'network_client.dart';

class NetworkDataRespone {
  NetworkDataRespone({
    required this.statusCode,
    required this.data,
    required this.isSuccess,
    required this.error,
  });

  int? statusCode;
  dynamic data;
  bool isSuccess;
  dynamic error;

  factory NetworkDataRespone.empty() => NetworkDataRespone(
    data: null,
    statusCode: null,
    error: null,
    isSuccess: false,
  );

  @override
  String toString() {
    return {
      'data': data,
      'statusCode': statusCode,
      'error': error,
      'isSuccess': isSuccess,
    }.toString();
  }
}
