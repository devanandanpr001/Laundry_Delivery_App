// import 'package:flutter/material.dart';
// import '../model/order_model.dart';
// import 'package:ziya_laundry_deliveryapp/Constants/Api_Constants.dart';
// import 'package:ziya_laundry_deliveryapp/core/dio_client.dart';

// class OrderService {
//   final DioClient _dioClient = DioClient();

//   Future<List<Map<String, dynamic>>> fetchOrdersFromApi() async {
//     try {
//       // Concurrent fetch for Pickup and Delivery orders to replace the static mock list
//       final results = await Future.wait([
//         _dioClient.get(ApiConstants.pickupOrders),
//         _dioClient.get(ApiConstants.deliveryOrders),
//       ]);

//       List<Map<String, dynamic>> allOrders = [];
      
//       final pickupResponse = results[0];
//       final deliveryResponse = results[1];

//       if (pickupResponse != null && pickupResponse['success'] == true && pickupResponse['data'] is List) {
//         allOrders.addAll((pickupResponse['data'] as List).map((e) => 
//           {...Map<String, dynamic>.from(e), 'orderType': 'pickup'}));
//       }

//       if (deliveryResponse != null && deliveryResponse['success'] == true && deliveryResponse['data'] is List) {
//         allOrders.addAll((deliveryResponse['data'] as List).map((e) => 
//           {...Map<String, dynamic>.from(e), 'orderType': 'delivery'}));
//       }

//       return allOrders;
//     } catch (e) {
//       debugPrint("OrderService fetchOrdersFromApi error: $e");
//       return [];
//     }
//   }

//   Future<void> updateOrderStatusOnApi(String orderId, OrderStatus status) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//   }


//   Future<List<Map<String, dynamic>>> fetchCompletedOrders() async {
//     try {
//       final response = await _dioClient.get(ApiConstants.completedOrders);
      
//       if (response != null && response['success'] == true) {
//         // The API response has a 'data' field which is a list of orders
//         return List<Map<String, dynamic>>.from(response['data']);
//       }
//       return [];
//     } catch (e) {
//       debugPrint("OrderService fetchCompletedOrders error: $e");
//       return [];
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/Orders/data/model/order_model.dart';
import 'package:ziya_laundry_deliveryapp/Constants/Api_Constants.dart';
import 'package:ziya_laundry_deliveryapp/core/dio_client.dart';

class OrderService {
  final DioClient _dioClient = DioClient();

Future<List<Map<String, dynamic>>> fetchOrdersFromApi() async {
  try {
    final results = await Future.wait([
      _dioClient.get(ApiConstants.pickupOrders),
      _dioClient.get(ApiConstants.deliveryOrders),
      _dioClient.get(ApiConstants.completedOrders),
    ]);

    List<Map<String, dynamic>> allOrders = [];

    final pickupResponse = results[0];
    final deliveryResponse = results[1];
    final completedResponse = results[2];

    if (pickupResponse != null &&
        pickupResponse['success'] == true &&
        pickupResponse['data'] is List) {
      allOrders.addAll(
        (pickupResponse['data'] as List).map(
          (e) => { ...Map<String, dynamic>.from(e), 'appOrderType': 'pickup' },
        ),
      );
    }

    if (deliveryResponse != null &&
        deliveryResponse['success'] == true &&
        deliveryResponse['data'] is List) {
      allOrders.addAll(
        (deliveryResponse['data'] as List).map(
          (e) => { ...Map<String, dynamic>.from(e), 'appOrderType': 'delivery' },
        ),
      );
    }

    if (completedResponse != null &&
        completedResponse['success'] == true &&
        (completedResponse['data'] is List || completedResponse['rows'] is List)) {
      final List rawData = completedResponse['data'] ?? completedResponse['rows'];
      
      // Strictly filter to only include 'DELIVERED' status as per request
      allOrders.addAll(
        rawData.where((e) => e['status']?.toString().toUpperCase() == 'DELIVERED').map(
          (e) {
            final String role = (e['roleType'] ?? e['role'] ?? '').toString().toUpperCase();
            // Determine appOrderType based on 'roleType' or 'role'
            final String appType = (role.contains('PICKUP') && !role.contains('DELIVERY')) ? 'pickup' : 'delivery';
            return { ...Map<String, dynamic>.from(e), 'appOrderType': appType, 'forceCompleted': true };
          },
        ),
      );
    }

    return allOrders;
  } catch (e) {
    debugPrint("OrderService fetchOrdersFromApi error: $e");
    return [];
  }
}

  Future<void> updateOrderStatusOnApi(String orderId, OrderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }


  Future<List<Map<String, dynamic>>> fetchCompletedOrders() async {
    try {
      final response = await _dioClient.get(ApiConstants.completedOrders);
      
      if (response != null && response['success'] == true) {
        final List rawData = response['data'] ?? [];
        // Strictly filter to only include 'DELIVERED' status
        return rawData.where((e) => e['status']?.toString().toUpperCase() == 'DELIVERED')
            .map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("OrderService fetchCompletedOrders error: $e");
      return [];
    }
  }
}