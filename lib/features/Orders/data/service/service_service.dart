import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/Constants/api_constants.dart';
import 'package:ziya_laundry_deliveryapp/core/network/dio_client.dart';

class ServiceService {
  final DioClient _dioClient = DioClient();

  Future<List<Map<String, dynamic>>> fetchAvailableServicesApi({String? orderId}) async {
    try {
      String url = ApiConstants.serviceAvailability;
      if (orderId != null && orderId.isNotEmpty) {
        url = "$url?orderId=$orderId";
      }

      final response = await _dioClient.get(url);
      if (response != null && response['success'] == true) {
        if (response['data'] is List) {
          return List<Map<String, dynamic>>.from(response['data']);
        }
        if (response['data'] is Map && response['data']['services'] is List) {
          return List<Map<String, dynamic>>.from(response['data']['services']);
        }
      }
    } catch (e) {
      debugPrint("ServiceService fetchAvailableServices Error: $e");
      rethrow;
    }
    return [];
  }

  Future<List<dynamic>> fetchItemsForServiceApi(String serviceId) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.selact_Items.replaceAll(':serviceId', serviceId),
      );
      if (response != null && response['success'] == true && response['data'] != null) {
        final List<dynamic> items = (response['data'] is Map) 
            ? (response['data']['items'] ?? []) 
            : (response['data'] ?? []);
        return items;
      }
    } catch (e) {
      debugPrint("ServiceService fetchItemsForService Error: $e");
      rethrow;
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchItemsForMultipleServicesApi(List<String> serviceIds) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.multipleServiceItems,
        data: {'serviceIds': serviceIds},
      );
      if (response != null && response['success'] == true && response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
    } catch (e) {
      debugPrint("ServiceService fetchItemsForMultipleServices Error: $e");
      rethrow;
    }
    return [];
  }
}