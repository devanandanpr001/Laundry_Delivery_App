import 'dart:async';
import 'package:ziya_laundry_deliveryapp/Constants/Api_Constants.dart';
import 'package:ziya_laundry_deliveryapp/Orders/data/model/order_model.dart';
import 'package:ziya_laundry_deliveryapp/core/dio_client.dart';

class HomeService {
  final DioClient _dioClient = DioClient();

  Future<List<Map<String, dynamic>>> fetchOrdersFromApi(OrderType orderType) async {
    String endpoint;
    if (orderType == OrderType.pickup) {
      endpoint = ApiConstants.pickupOrders;
    } else {
      endpoint = ApiConstants.deliveryOrders;
    }

    final response = await _dioClient.get(endpoint);
    if (response != null && response['success'] == true && response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    return [];
  }

  // New method to fetch all orders (pickup and delivery)
  Future<List<OrderModel>> fetchAllOrders() async {
    try {
      final pickupOrdersData = await fetchOrdersFromApi(OrderType.pickup);
      final deliveryOrdersData = await fetchOrdersFromApi(OrderType.delivery);

      final List<OrderModel> allOrders = [];
      for (var orderJson in pickupOrdersData) {
        allOrders.add(OrderModel.fromJson(orderJson, OrderType.pickup));
      }
      for (var orderJson in deliveryOrdersData) {
        allOrders.add(OrderModel.fromJson(orderJson, OrderType.delivery));
      }
      return allOrders;
    } catch (e) {
      // Handle error or rethrow
      print("Error fetching all orders: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>> getDashboardCountsFromApi() async {
    final response = await _dioClient.get(ApiConstants.dashboardCounts);
    if (response != null && 
        response['success'] == true && 
        response['data'] != null) {
      // Return only the inner data: {"assignedCount": X, "completedCount": Y}
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