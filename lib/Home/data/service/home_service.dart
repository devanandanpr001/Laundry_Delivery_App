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
      return (response['data'] as List)
          .map((item) => _mapOrderImages(Map<String, dynamic>.from(item)))
          .toList();
    }
    return [];
  }

  Future<List<OrderModel>> fetchAssignedOrders() async {
    final response = await _dioClient.get(ApiConstants.assignedOrders);
    if (response != null && response['success'] == true && response['data'] is List) {
      return (response['data'] as List).map((json) {
        final processedJson = _mapOrderImages(Map<String, dynamic>.from(json));
        final type = processedJson['role'] == 'DELIVERY' ? OrderType.delivery : OrderType.pickup;
        return OrderModel.fromJson(processedJson, type, forceAssigned: true);
      }).toList();
    }
    return [];
  }

  // New method to fetch all orders (pickup and delivery)
  Future<List<OrderModel>> fetchAllOrders() async {
    try {
      // Concurrent fetch for efficiency
      // Using individual try-catches or selective waiting is safer, 
      // but we will ensure we handle the mapping correctly.
      final List<Map<String, dynamic>> pickupData = await fetchOrdersFromApi(OrderType.pickup);
      final List<Map<String, dynamic>> deliveryData = await fetchOrdersFromApi(OrderType.delivery);
      final List<OrderModel> assignedOrders = await fetchAssignedOrders();

      final List<OrderModel> allOrders = [];
      
      for (var orderJson in pickupData) {
        allOrders.add(OrderModel.fromJson(orderJson, OrderType.pickup));
      }
      for (var orderJson in deliveryData) {
        allOrders.add(OrderModel.fromJson(orderJson, OrderType.delivery));
      }
      
      // Filter out duplicates if assigned orders also appear in pickup/delivery lists
      allOrders.addAll(assignedOrders);

      return allOrders;
    } catch (e) {
      print("Error fetching all orders: $e");
      return [];
    }
  }

  Future<List<OrderModel>> fetchCompletedOrders() async {
    final response = await _dioClient.get(ApiConstants.completedOrders);
    if (response != null && response['success'] == true && response['data'] is List) {
      return (response['data'] as List).map((json) {
        // Defaulting to delivery type for completed session orders; 
        // roles can be checked if the backend provides them.
        final processedJson = _mapOrderImages(Map<String, dynamic>.from(json));
        final type = processedJson['role'] == 'PICKUP' ? OrderType.pickup : OrderType.delivery;
        return OrderModel.fromJson(processedJson, type);
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

  Future<bool> markOrderDeliveredApi(String orderId) async {
    final response = await _dioClient.post(ApiConstants.markDelivered, data: {'orderId': orderId});
    return response != null && response['success'] == true;
  }

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

  /// Helper to prepend base URL to order images professionally
  Map<String, dynamic> _mapOrderImages(Map<String, dynamic> json) {
    // 1. Sanitize Numeric Fields (Crucial fix for "type 'String' is not a subtype of type 'num?'")
    // This handles cases where the API sends decimals or counts as Strings.
    final numericFields = [
      'totalAmount', 'paidAmount', 'payableAmount', 'unitPrice', 
      'totalPrice', 'collectedAmount', 'orderNumber', 'quantity'
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
    if (json.containsKey('pickedImages') && json['pickedImages'] is List) {
      json['pickedImages'] = (json['pickedImages'] as List).map((img) {
        // Extracts filePath if the image is an object (common with DB joins) or uses the string directly
        final String path = (img is Map) ? (img['filePath'] ?? img['path'] ?? "").toString() : img.toString();
        if (path.isNotEmpty && !path.startsWith('http')) {
          // Ensures the image path is a valid network URL
          return '${ApiConstants.mediaBaseUrl}${path.startsWith('/') ? path.substring(1) : path}';
        }
        return path;
      }).toList();
    }
    return json;
  }
}