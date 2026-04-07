import 'package:flutter/foundation.dart';
import '../../../../core/constants/endpoints.dart';
import '../models/home_model.dart';
import '../../../../core/services/api_helper.dart';

class HomeProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  HomeModel? _homeData;
  HomeModel? get homeData => _homeData;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiHelper.get(Endpoints.home);

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        _homeData = HomeModel.fromJson(response['data']);
      } else {
        _errorMessage = response['message'] ?? 'Failed to fetch home data';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _homeData = null;
    _errorMessage = null;
    notifyListeners();
  }

  void onAuthChanged(bool isAuthenticated) {
    if (isAuthenticated) {
      fetchHomeData();
    } else {
      clearData();
    }
  }
}
