import 'dart:async';
import 'package:ziya_laundry_deliveryapp/Constants/api_constants.dart';
import 'package:ziya_laundry_deliveryapp/core/network/dio_client.dart';

class HomeService {
  final DioClient _dioClient = DioClient();

  Future<Map<String, dynamic>> getDashboardCountsFromApi() async {
    final response = await _dioClient.get(ApiConstants.dashboardCounts);
    if (response != null && 
        response['success'] == true && 
        response['data'] != null) {
      return Map<String, dynamic>.from(response['data']);
    }
    return {};
  }

  Future<Map<String, dynamic>?> fetchProfile() async {
    final response = await _dioClient.get(ApiConstants.profile);
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
    final response = await _dioClient.put(ApiConstants.onlineStatus, data: {'isOnline': isOnline});
    return response != null && response['success'] == true;
  }
}