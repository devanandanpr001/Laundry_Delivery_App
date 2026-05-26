import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/Constants/Api_Constants.dart';
import 'package:ziya_laundry_deliveryapp/Orders/data/model/order_model.dart';
import 'package:ziya_laundry_deliveryapp/core/dio_client.dart';
import 'package:dio/dio.dart';

// Helper to fetch and parse orders from a given endpoint
Future<List<OrderModel>> _fetchAndParseOrders(
    DioClient dioClient, String endpoint, OrderType orderType,
    {bool forceAssigned = false, bool forceCompleted = false}) async {
  final response = await dioClient.get(endpoint);
  if (response != null && response['success'] == true && response['data'] is List) {
    final List rawData = response['data'] as List;
    
    final Iterable dataToParse = rawData;

    return dataToParse.map((json) {
      final Map<String, dynamic> rawJson = Map<String, dynamic>.from(json);
      // Inject metadata for parsing
      rawJson['appOrderType'] = orderType.name; 
      return OrderModel.fromJson(rawJson, orderType, forceAssigned: forceAssigned, forceCompleted: forceCompleted);
    }).toList();
  }
  return [];
}

class OrderService {
  final DioClient _dioClient = DioClient();

  Future<List<OrderModel>> fetchOrdersFromApi(OrderType orderType) async {
    String endpoint;
    if (orderType == OrderType.pickup) {
      endpoint = ApiConstants.pickupOrders;
    } else {
      endpoint = ApiConstants.deliveryOrders;
    }
    return _fetchAndParseOrders(_dioClient, endpoint, orderType);
  }

  Future<List<OrderModel>> fetchPickupAssignedOrders() =>
      _fetchAndParseOrders(_dioClient, ApiConstants.pickupAssignedOrders, OrderType.pickup, forceAssigned: true);

  Future<List<OrderModel>> fetchPickupCompletedOrders() =>
      _fetchAndParseOrders(_dioClient, ApiConstants.pickupCompletedOrders, OrderType.pickup, forceCompleted: true);

  Future<List<OrderModel>> fetchDeliveryAssignedOrders() =>
      _fetchAndParseOrders(_dioClient, ApiConstants.deliveryAssignedOrders, OrderType.delivery, forceAssigned: true);

  Future<List<OrderModel>> fetchDeliveryCompletedOrders() =>
      _fetchAndParseOrders(_dioClient, ApiConstants.deliveryCompletedOrders, OrderType.delivery, forceCompleted: true);

  Future<List<OrderModel>> fetchAllOrders() async {
    try {
      final response = await _dioClient.get(ApiConstants.completedOrders);
      if (response != null && response['success'] == true && response['data'] is List) {
        final allOrdersData = List<Map<String, dynamic>>.from(response['data']);
        return allOrdersData.map((json) {
          final parsedJson = Map<String, dynamic>.from(json);
          return OrderModel.fromJson(parsedJson, OrderType.pickup);
        }).toList();
      }
    } catch (e) {
      debugPrint("OrderService fetchAllOrders fallback: $e");
    }

    // Fallback to existing multi-endpoint fetch when /orders/all is unavailable.
    try {
      final results = await Future.wait([
        fetchOrdersFromApi(OrderType.pickup).catchError((_) => <OrderModel>[]),
        fetchOrdersFromApi(OrderType.delivery).catchError((_) => <OrderModel>[]),
        fetchPickupAssignedOrders().catchError((_) => <OrderModel>[]),
        fetchDeliveryAssignedOrders().catchError((_) => <OrderModel>[]),
        fetchPickupCompletedOrders().catchError((_) => <OrderModel>[]),
        fetchDeliveryCompletedOrders().catchError((_) => <OrderModel>[]),
      ]);

      final Map<String, OrderModel> orderMap = {};

      for (var orderList in results) {
        for (var order in orderList) {
          final String key = "${order.orderId}_${order.orderType.name}";
          final OrderModel? existingOrder = orderMap[key];
          if (existingOrder == null ||
              (order.status == OrderStatus.assigned && existingOrder.status == OrderStatus.pending) ||
              (order.status == OrderStatus.completed && (existingOrder.status == OrderStatus.pending || existingOrder.status == OrderStatus.assigned))) {
            orderMap[key] = order;
          }
        }
      }
      return orderMap.values.toList();
    } catch (e) {
      debugPrint("Error fetching all orders: $e");
      rethrow;
    }
  }

  Future<bool> confirmPickupOrder(String orderId) async {
    final response = await _dioClient.post(
      ApiConstants.confirmPickup.replaceAll(':orderId', orderId),
    );
    return response != null && response['success'] == true;
  }

  Future<bool> acceptPickupOrder(String orderId) async {
    final response = await _dioClient.post(ApiConstants.acceptPickup, data: {'orderId': orderId});
    return response != null && response['success'] == true;
  }

  Future<bool> acceptDeliveryOrder(String orderId) async {
    final response = await _dioClient.post(ApiConstants.acceptDelivery, data: {'orderId': orderId});
    return response != null && response['success'] == true;
  }

  Future<bool> verifyOrderApi(String orderId) async {
    final response = await _dioClient.patch(
      "${ApiConstants.verifyOrder}/$orderId/verify",
    );
    return response != null && response['success'] == true;
  }

  Future<bool> reportMismatchApi(String orderId, String details) async {
    final response = await _dioClient.put(
      ApiConstants.mismatch.replaceAll(':orderId', orderId),
      data: {"mismatchReason": details},
    );
    return response != null && response['success'] == true;
  }

  Future<void> addItemApi(String orderId, Map<String, dynamic> payload) async {
    final response = await _dioClient.post(
      "${ApiConstants.orderItem}/$orderId/item",
      data: payload,
    );
    if (response == null || response['success'] != true) {
      throw Exception("API failed to add item");
    }
  }

  Future<void> deleteItemApi(String orderId, String itemId) async {
    final response = await _dioClient.delete(
      "${ApiConstants.orderItem}/$orderId/item",
      data: {"itemId": itemId},
    );
    if (response == null || response['success'] != true) {
      throw Exception("API failed to delete item");
    }
  }

  Future<Map<String, String>?> uploadOrderImageApi(String orderId, String imagePath) async {
    final String fileName = imagePath.split(RegExp(r'[/\\]')).last;
    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(imagePath, filename: fileName),
    });
    final response = await _dioClient.post(
      "${ApiConstants.uploadOrderImage}/$orderId/upload-image",
      data: formData,
    );
    if (response != null && response['success'] == true && response['data'] != null) {
      return {
        'imageUrl': response['data']['imageUrl']?.toString() ?? '',
        'id': response['data']['id']?.toString() ?? '',
      };
    }
    return null;
  }

  Future<bool> deleteOrderImageApi(String orderId, String imageId) async {
    final url = "${ApiConstants.uploadOrderImage}/$orderId/upload-image/$imageId";
    final response = await _dioClient.delete(url);
    return response != null && response['success'] == true;
  }

  Future<bool> sendDeliveryOtpApi(String orderId) async {
    final response = await _dioClient.post(
      ApiConstants.deliverysendotp.replaceAll(':orderId', orderId),
    );
    return response != null && response['success'] == true;
  }

  Future<bool> verifyDeliveryOtpApi(String orderId, String otp) async {
    final response = await _dioClient.post(
      ApiConstants.deliveryverifyotp.replaceAll(':orderId', orderId),
      data: {'otp': otp},
    );
    return response != null && response['success'] == true;
  }
}