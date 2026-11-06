import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Answers API calls with canned JSON by path and records what was sent.
class FakeApi implements HttpClientAdapter {
  final Map<String, Map<String, dynamic>> replies = {};
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final reply = replies[options.path];
    return ResponseBody.fromString(
      jsonEncode(reply ?? {'message': 'not found'}),
      reply == null ? 404 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
