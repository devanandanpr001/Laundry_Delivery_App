import 'dart:async';

class HomeService {
  // Mock API interaction. Replace with actual http/dio calls.
  Future<List<Map<String, dynamic>>> fetchOrdersFromApi() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return []; // Return raw JSON list from backend
  }

  Future<bool> updateOrderStatusOnApi(String orderId, String status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<bool> getOnlineStatusFromApi() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }
}