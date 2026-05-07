import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/Constants/Api_Constants.dart';
import 'package:ziya_laundry_deliveryapp/Orders/data/model/order_model.dart';
import 'package:ziya_laundry_deliveryapp/core/dio_client.dart';

// Helper to prepend base URL to order images professionally
Map<String, dynamic> _mapOrderImages(Map<String, dynamic> json) {
  // 1. Sanitize Numeric Fields (Crucial fix for "type 'String' is not a subtype of type 'num?'")
  // This handles cases where the API sends decimals or counts as Strings.
  final numericFields = [
    'totalAmount', 'paidAmount', 'payableAmount', 'unitPrice', 
    'totalPrice', 'collectedAmount', 'orderNumber', 'quantity',
    'pricePerKg' // Added pricePerKg for completeness
  ];
  
  void sanitize(Map<String, dynamic> data) {
    for (var field in numericFields) {
      if (data.containsKey(field) && data[field] != null) {
        if (data[field] is String) {
          if (field == 'orderNumber' || field == 'quantity') {
            data[field] = int.tryParse(data[field]) ?? (double.tryParse(data[field])?.toInt() ?? 0);
          } else {
            data[field] = double.tryParse(data[field]) ?? 0.0;
          }
        }
      }
    }
  }

  sanitize(json);
  
  // Sanitize root-level details map if present (Crucial for Assigned Orders)
  final detailsKeys = ['Pickup', 'Delivery', 'pickup', 'delivery'];
  for (var key in detailsKeys) {
    if (json[key] != null && json[key] is Map) {
      sanitize(json[key] as Map<String, dynamic>);
    }
  }

  // Sanitize nested items (handles both 'OrderItems' and 'items' keys used by different endpoints)
  final nestedKeys = ['OrderItems', 'items'];
  for (var key in nestedKeys) {
    if (json[key] != null && json[key] is List) {
      json[key] = (json[key] as List).map((item) {
        if (item is Map) {
          final itemMap = Map<String, dynamic>.from(item);
          sanitize(itemMap);
          return itemMap;
        }
        return item;
      }).toList();
    }
  }

  // 2. Prepend base URL to image paths
  void mapImages(Map<String, dynamic> data) {
    final imageFields = ['pickedImages', 'images'];
    for (var field in imageFields) {
      if (data.containsKey(field) && data[field] is List) {
        data[field] = (data[field] as List).map((img) {
          if (img is Map) {
            final imgMap = Map<String, dynamic>.from(img);
            final String path = (imgMap['filePath'] ?? imgMap['path'] ?? imgMap['imageUrl'] ?? "").toString();
            if (path.isNotEmpty && !path.startsWith('http')) {
              imgMap['imageUrl'] = '${ApiConstants.mediaBaseUrl}${path.startsWith('/') ? path.substring(1) : path}';
            } else if (path.isNotEmpty) {
              imgMap['imageUrl'] = path;
            }
            return imgMap;
          }
          final String path = img.toString();
          if (path.isNotEmpty && !path.startsWith('http')) {
            return '${ApiConstants.mediaBaseUrl}${path.startsWith('/') ? path.substring(1) : path}';
          }
          return path;
        }).toList();
      }
    }
  }

  mapImages(json);
  for (var key in detailsKeys) {
    if (json[key] != null && json[key] is Map) {
      mapImages(json[key] as Map<String, dynamic>);
    }
  }

  return json;
}

// Helper to fetch and parse orders from a given endpoint
Future<List<OrderModel>> _fetchAndParseOrders(
    DioClient dioClient, String endpoint, OrderType orderType,
    {bool forceAssigned = false, bool forceCompleted = false}) async {
  final response = await dioClient.get(endpoint);
  if (response != null && response['success'] == true && response['data'] is List) {
    return (response['data'] as List).map((json) {
      // Assuming OrderModel.fromJson can handle forceAssigned and forceCompleted
      // If not, you'll need to update your OrderModel.dart
      final processedJson = _mapOrderImages(Map<String, dynamic>.from(json));
      return OrderModel.fromJson(processedJson, orderType, forceAssigned: forceAssigned, forceCompleted: forceCompleted);
    }).toList();
  }
  return [];
}
class HomeService {
  final DioClient _dioClient = DioClient();

  Future<List<OrderModel>> fetchOrdersFromApi(OrderType orderType) async {
    String endpoint;
    if (orderType == OrderType.pickup) {
      endpoint = ApiConstants.pickupOrders;
    } else {
      endpoint = ApiConstants.deliveryOrders;
    }

    // These are typically pending orders, so no forceAssigned/Completed
    return _fetchAndParseOrders(_dioClient, endpoint, orderType);
  }

  // NEW: Specific assigned and completed endpoints
  Future<List<OrderModel>> fetchPickupAssignedOrders() =>
      _fetchAndParseOrders(_dioClient, ApiConstants.pickupAssignedOrders, OrderType.pickup, forceAssigned: true);

  Future<List<OrderModel>> fetchPickupCompletedOrders() =>
      _fetchAndParseOrders(_dioClient, ApiConstants.pickupCompletedOrders, OrderType.pickup, forceCompleted: true);

  Future<List<OrderModel>> fetchDeliveryAssignedOrders() =>
      _fetchAndParseOrders(_dioClient, ApiConstants.deliveryAssignedOrders, OrderType.delivery, forceAssigned: true);

  Future<List<OrderModel>> fetchDeliveryCompletedOrders() =>
      _fetchAndParseOrders(_dioClient, ApiConstants.deliveryCompletedOrders, OrderType.delivery, forceCompleted: true);

  Future<bool> confirmPickupOrder(String orderId) async {
    final response = await _dioClient.post(
      ApiConstants.confirmPickup.replaceAll(':orderId', orderId),
    );
    return response != null && response['success'] == true;
  }

  // New method to fetch all orders (pickup and delivery)
  Future<List<OrderModel>> fetchAllOrders() async {
    try {
      // Fetch all categories using a safety wrapper so one failing endpoint doesn't crash the whole UI
      final results = await Future.wait([
        fetchOrdersFromApi(OrderType.pickup).catchError((_) => <OrderModel>[]),
        fetchOrdersFromApi(OrderType.delivery).catchError((_) => <OrderModel>[]),
        fetchPickupAssignedOrders().catchError((_) => <OrderModel>[]),
        fetchDeliveryAssignedOrders().catchError((_) => <OrderModel>[]),
        fetchPickupCompletedOrders().catchError((_) => <OrderModel>[]),
        fetchDeliveryCompletedOrders().catchError((_) => <OrderModel>[]),
      ]);

      // Use a Map to handle duplicates by orderId
      // Status priority: completed > assigned > pending
      final Map<String, OrderModel> orderMap = {};

      // Results index: 0,1 (Pending), 2,3 (Assigned), 4,5 (Completed)
      // This ensures the latest and most specific status is retained.
      for (var orderList in results) {
        for (var order in orderList) {
          // Cast to OrderModel to access properties
          final OrderModel? existingOrder = orderMap[order.orderId];
          if (existingOrder == null ||
              (order.status == OrderStatus.assigned && existingOrder.status == OrderStatus.pending) ||
              (order.status == OrderStatus.completed && (existingOrder.status == OrderStatus.pending || existingOrder.status == OrderStatus.assigned))) {
            orderMap[order.orderId] = order;
          }
        }
      }

      return orderMap.values.toList();
    } catch (e) {
      debugPrint("Error fetching all orders: $e");
      return [];
    }
  }

  Future<List<OrderModel>> fetchCompletedOrders() async {
    final response = await _dioClient.get(ApiConstants.completedOrders);
    if (response != null && response['success'] == true && response['data'] is List) {
      return (response['data'] as List).map((json) {
        final processedJson = _mapOrderImages(Map<String, dynamic>.from(json));
        final String role = processedJson['role']?.toString().toUpperCase() ?? "";
        final type = role == 'PICKUP' ? OrderType.pickup : OrderType.delivery;
        return OrderModel.fromJson(processedJson, type, forceCompleted: true);
      }).toList();
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

  Future<bool> acceptPickupOrder(String orderId) async {
    final response = await _dioClient.post(ApiConstants.acceptPickup, data: {'orderId': orderId});
    return response != null && response['success'] == true;
  }

  Future<bool> acceptDeliveryOrder(String orderId) async {
    final response = await _dioClient.post(ApiConstants.acceptDelivery, data: {'orderId': orderId});
    return response != null && response['success'] == true;
  }

  // Future<bool> markOrderDeliveredApi(String orderId) async {
  //   final response = await _dioClient.post(ApiConstants.markDelivered, data: {'orderId': orderId});
  //   return response != null && response['success'] == true;
  // }

  Future<Map<String, dynamic>?> fetchProfile() async {
    final response = await _dioClient.get(ApiConstants.profile);
    // Extracting 'user' key as per the backend response log
    if (response != null && response['success'] == true && response['user'] != null) {
      final userData = Map<String, dynamic>.from(response['user']);
      
      // Ensure the profile image is a full URL if it's a relative path
      String? pImg = userData['profileImage']?.toString();
      if (pImg != null && pImg.isNotEmpty && !pImg.startsWith('http')) {
        userData['profileImage'] = '${ApiConstants.mediaBaseUrl}$pImg';
      }
      
      return userData;
    }
    return null;
  }

  Future<bool> updateOnlineStatusApi(bool isOnline) async {
    final response = await _dioClient.patch(ApiConstants.onlineStatus, data: {'isOnline': isOnline});
    return response != null && response['success'] == true;
  }

  Future<List<Map<String, dynamic>>> fetchAvailableServices() async {
    final response = await _dioClient.get(ApiConstants.serviceAvailability);
    if (response != null && response['success'] == true && response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    return [];
  }

  Future<Map<String, dynamic>?> fetchServiceItems(String serviceId) async {
    final response = await _dioClient.get(
      ApiConstants.selact_Items.replaceAll(':serviceId', serviceId),
    );
    if (response != null && response['success'] == true) {
      return response['data'];
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> fetchMultipleServiceItems(List<String> serviceIds) async {
    final response = await _dioClient.post(
      ApiConstants.multipleServiceItems,
      data: {'serviceIds': serviceIds},
    );
    if (response != null && response['success'] == true && response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    return [];
  }
}