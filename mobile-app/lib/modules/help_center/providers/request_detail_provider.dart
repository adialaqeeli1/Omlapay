import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/services/device_identifier_service.dart';
import '../../../core/utils/app_exception.dart';
import '../../../providers/auth_provider.dart';
import '../models/support_request_detail_model.dart';
import '../services/help_center_service.dart';

class RequestDetailProvider extends ChangeNotifier {
  final HelpCenterService _service;
  final AuthProvider _authProvider;
  final String requestId;
  String? _cachedMacAddress;

  RequestDetailProvider({
    required this.requestId,
    required AuthProvider authProvider,
    HelpCenterService? service,
  }) : _authProvider = authProvider,
       _service = service ?? HelpCenterService() {
    fetchDetail();
  }

  bool get isGuest => !_authProvider.state.isAuthenticated;

  Future<String?> _resolveMacAddress() async {
    if (!isGuest) return null;
    _cachedMacAddress ??= await DeviceIdentifierService.instance
        .getDeviceIdentifier();
    return _cachedMacAddress;
  }

  SupportRequestDetailModel? _detail;
  bool _isLoading = false;
  String? _errorKey;
  final Map<String, int?> _fileSizes = {};
  final Set<String> _collapsedItemIds = {};

  static const String requestItemId = '__request__';

  SupportRequestDetailModel? get detail => _detail;
  bool get isLoading => _isLoading;
  String? get errorKey => _errorKey;

  int? getFileSizeForUrl(String url) => _fileSizes[url];

  bool isItemExpanded(String itemId) => !_collapsedItemIds.contains(itemId);

  void toggleItemExpansion(String itemId) {
    if (_collapsedItemIds.contains(itemId)) {
      _collapsedItemIds.remove(itemId);
    } else {
      _collapsedItemIds.add(itemId);
    }
    notifyListeners();
  }

  Future<void> fetchDetail({isRefresh = false}) async {
    if (!isRefresh) _isLoading = true;
    _errorKey = null;
    notifyListeners();

    try {
      final macAddress = await _resolveMacAddress();
      _detail = await _service.fetchRequestDetail(
        requestId,
        macAddress: macAddress,
      );
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
