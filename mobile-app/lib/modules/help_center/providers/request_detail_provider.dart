import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/app_exception.dart';
import '../models/support_request_detail_model.dart';
import '../services/help_center_service.dart';

class RequestDetailProvider extends ChangeNotifier {
  final HelpCenterService _service;
  final String requestId;

  RequestDetailProvider({
    required this.requestId,
    HelpCenterService? service,
  }) : _service = service ?? HelpCenterService() {
    fetchDetail();
  }

  SupportRequestDetailModel? _detail;
  bool _isLoading = false;
  bool _isReopening = false;
  String? _errorKey;
  final Map<String, int?> _fileSizes = {};

  SupportRequestDetailModel? get detail => _detail;
  bool get isLoading => _isLoading;
  bool get isReopening => _isReopening;
  String? get errorKey => _errorKey;

  int? getFileSizeForUrl(String url) => _fileSizes[url];

  Future<void> fetchDetail() async {
    _isLoading = true;
    _errorKey = null;
    notifyListeners();

    try {
      _detail = await _service.fetchRequestDetail(requestId);
      // Fetch file sizes for all attachments
      for (final attachment in _detail!.attachments) {
        _fetchFileSize(attachment.url);
      }
    } on AppException catch (e) {
      _errorKey = e.messageKey ?? 'requestFailed';
    } catch (_) {
      _errorKey = 'failedToLoadRequestDetail';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reopenTicket() async {
    if (_isReopening) return;

    _isReopening = true;
    notifyListeners();

    try {
      await _service.reopenRequest(requestId);
      await fetchDetail();
    } on AppException catch (e) {
      _errorKey = e.messageKey ?? 'failedToReopenRequest';
    } catch (_) {
      _errorKey = 'failedToReopenRequest';
    } finally {
      _isReopening = false;
      notifyListeners();
    }
  }

  Future<void> _fetchFileSize(String url) async {
    if (_fileSizes.containsKey(url)) return;

    try {
      final dio = Dio();
      final response = await dio.head(url);
      final contentLength = int.tryParse(
        response.headers.value('content-length') ?? '',
      );
      _fileSizes[url] = contentLength;
      notifyListeners();
    } catch (_) {
      _fileSizes[url] = null;
    }
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String extractFileName(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    if (segments.isNotEmpty) {
      return Uri.decodeComponent(segments.last);
    }
    return 'attachment';
  }
}
