import 'dart:async';
import 'package:ziya_laundry_deliveryapp/Constants/Api_Constants.dart';
import 'package:ziya_laundry_deliveryapp/core/dio_client.dart';

class HomeService {
  final DioClient _dioClient = DioClient();

  Future<List<Map<String, dynamic>>> fetchOrdersFromApi() async {
    final response = await _dioClient.get(ApiConstants.allOrders);
    if (response != null && response['success'] == true && response['data'] != null) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    return [];
  }

  Future<Map<String, dynamic>> getDashboardCountsFromApi() async {
    final response = await _dioClient.get(ApiConstants.dashboardCounts);
    if (response != null && response['success'] == true && response['data'] != null) {
      return Map<String, dynamic>.from(response['data']);
    }
    return {};
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