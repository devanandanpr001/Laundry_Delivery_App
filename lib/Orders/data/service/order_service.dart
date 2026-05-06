import 'package:flutter/material.dart';
import '../model/order_model.dart';
import 'package:ziya_laundry_deliveryapp/Constants/Api_Constants.dart';
import 'package:ziya_laundry_deliveryapp/core/dio_client.dart';

class OrderService {
  final DioClient _dioClient = DioClient();

  /// Mock data simulating an API response
  Future<List<Map<String, dynamic>>> fetchOrdersFromApi() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network lag
    return [
      /// -------- PICKUP ORDERS --------
      {
        "orderId": "#ORD-001",
        "name": "Rahul",
        "by": "By Weight",
        "address": "Kochi, Kerala",
        "isPaid": false,
        "status": "PENDING",
        "orderType": "PICKUP",
        "items": [{"name": "Shirt", "qty": "2"}],
      },
      {
        "orderId": "#ORD-002",
        "name": "Arjun",
        "by": "Per Piece",
        "address": "Aluva, Kerala",
        "isPaid": true,
        "status": "ASSIGNED",
        "orderType": "PICKUP",
        "items": [],
      },
      {
        "orderId": "#ORD-003",
        "name": "Meera",
        "by": "Per Piece",
        "address": "Edappally, Kochi",
        "isPaid": false,
        "status": "PENDING",
        "orderType": "PICKUP",
        "items": [],
      },
      {
        "orderId": "#ORD-004",
        "name": "Anu",
        "by": "By Weight",
        "address": "Kakkanad, Kochi",
        "isPaid": true,
        "status": "COMPLETED",
        "orderType": "PICKUP",
        "items": [],
      },
      /// -------- DELIVERY ORDERS --------
      {
        "orderId": "#ORD-005",
        "name": "Vishnu",
        "by": "Per Piece",
        "address": "Thrippunithura, Kerala",
        "isPaid": true,
        "status": "PENDING",
        "orderType": "DELIVERY",
        "items": [],
      },
      {
        "orderId": "#ORD-006",
        "name": "Sreya",
        "by": "By Weight",
        "address": "Kaloor, Kochi",
        "isPaid": false,
        "status": "ASSIGNED",
        "orderType": "DELIVERY",
        "items": [],
      },
      {
        "orderId": "#ORD-007",
        "name": "Nithin",
        "by": "Per Piece",
        "address": "Palarivattom, Kochi",
        "isPaid": true,
        "status": "PENDING",
        "orderType": "DELIVERY",
        "items": [],
      },
      {
        "orderId": "#ORD-008",
        "name": "Athira",
        "by": "By Weight",
        "address": "Fort Kochi, Kerala",
        "isPaid": true,
        "status": "COMPLETED",
        "orderType": "DELIVERY",
        "items": [],
      },
    ];
  }

  Future<void> updateOrderStatusOnApi(String orderId, OrderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Fetches completed orders from the real API
  Future<List<Map<String, dynamic>>> fetchCompletedOrders() async {
    try {
      final response = await _dioClient.get(ApiConstants.completedOrders);
      
      if (response != null && response['success'] == true) {
        // The API response has a 'data' field which is a list of orders
        return List<Map<String, dynamic>>.from(response['data']);
      }
      return [];
    } catch (e) {
      debugPrint("OrderService fetchCompletedOrders error: $e");
      return [];
    }
  }
}