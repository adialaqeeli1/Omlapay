class AppException implements Exception {
  final String message;
  final String? messageKey;

  AppException(this.message, {this.messageKey});

  @override
  String toString() => message;
}
