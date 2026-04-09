import 'package:flutter/material.dart';

import '../../../core/utils/app_exception.dart';
import '../models/support_request_model.dart';
import '../services/help_center_service.dart';
import '../widgets/filter_bottom_sheet.dart';

class HelpCenterProvider extends ChangeNotifier {
  final HelpCenterService _service;

  HelpCenterProvider({HelpCenterService? service})
      : _service = service ?? HelpCenterService();

  List<SupportRequestModel> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  int _currentPage = 1;
  int _totalPages = 1;
  FilterOption _selectedFilter = FilterOption.all;
  String? _errorKey;

  List<SupportRequestModel> get items => _items;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  FilterOption get selectedFilter => _selectedFilter;
  String? get errorKey => _errorKey;

  String? get _statusParam {
    switch (_selectedFilter) {
      case FilterOption.all:
        return null;
      case FilterOption.solved:
        return 'SOLVED';
      case FilterOption.pending:
        return 'OPEN';
      case FilterOption.rejected:
        return 'REJECTED';
    }
  }

  Future<void> fetchRequests() async {
    _isLoading = true;
    _errorKey = null;
    _currentPage = 1;
    notifyListeners();

    try {
      final response = await _service.fetchSupportRequests(
        status: _statusParam,
        page: _currentPage,
      );
      _items = response.requests;
      _totalPages = response.pagination?.totalPages ?? 1;
      _hasMore = _currentPage < _totalPages;
    } on AppException catch (e) {
      _errorKey = e.messageKey ?? 'requestFailed';
    } catch (_) {
      _errorKey = 'failedToLoadSupportRequests';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final response = await _service.fetchSupportRequests(
        status: _statusParam,
        page: _currentPage,
      );
      _items = [..._items, ...response.requests];
      _totalPages = response.pagination?.totalPages ?? 1;
      _hasMore = _currentPage < _totalPages;
    } on AppException catch (e) {
      _currentPage--;
      _errorKey = e.messageKey ?? 'requestFailed';
    } catch (_) {
      _currentPage--;
      _errorKey = 'failedToLoadMoreRequests';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void setFilter(FilterOption filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    fetchRequests();
  }
}
