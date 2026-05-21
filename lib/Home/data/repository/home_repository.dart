import 'package:ziya_laundry_deliveryapp/Home/data/service/home_service.dart';

class HomeRepository {
  final HomeService _service;

  HomeRepository(this._service);

  Future<Map<String, dynamic>> getDashboardCounts() => _service.getDashboardCountsFromApi();
  Future<Map<String, dynamic>?> getProfile() => _service.fetchProfile();
  Future<bool> getInitialOnlineStatus() async {
    final profile = await _service.fetchProfile();
    return profile?['isOnline'] ?? false;
  }
}