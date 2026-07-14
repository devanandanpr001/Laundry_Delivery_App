import 'package:flutter/foundation.dart';
import 'package:ziya_laundry_deliveryapp/Constants/api_constants.dart';
import 'package:ziya_laundry_deliveryapp/core/network/dio_client.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/data/model/order_model.dart';

class MyOrdersService {
  final DioClient _dioClient = DioClient();

  Future<List<OrderModel>> fetchMyCompletedOrders() async {
    try {
      final response = await _dioClient.get(ApiConstants.completedOrders);
      if (response != null && response['success'] == true && response['data'] is List) {
        final allOrdersData = List<Map<String, dynamic>>.from(response['data']);
        return allOrdersData.map((json) {
          return OrderModel.fromJson(json, OrderType.delivery, forceCompleted: true);
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint("MyOrdersService fetchMyCompletedOrders Error: $e");
      rethrow;
    }
  }
}